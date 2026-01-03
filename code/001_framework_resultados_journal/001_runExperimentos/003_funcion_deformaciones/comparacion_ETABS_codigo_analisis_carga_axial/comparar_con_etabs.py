#!/usr/bin/env python3
"""
COMPARAR_CON_ETABS - Comparación automática de cargas axiales

Compara los resultados de fuerzas axiales calculadas en MATLAB contra
los valores obtenidos de ETABS (combinación DEAD + TOPSIDE).

Archivos de entrada:
  - N_axial_codigo.csv: Salida de main_comparacion_etabs.m
  - 001_runExperimentos/003_funcion_deformaciones/P_etabs_promedio.csv: Datos ETABS

Salida:
  - Reporte en consola con estadísticas de comparación
  - comparacion_resultados.csv: Tabla comparativa detallada
  - comparacion_estadisticas.txt: Resumen estadístico

Autor: Sistema de análisis estructural
Fecha: Enero 2026
"""

import pandas as pd
import numpy as np
import os
from pathlib import Path

def main():
    print("=" * 80)
    print("  COMPARACIÓN: CÓDIGO MATLAB vs ETABS")
    print("=" * 80)
    print()
    
    # =========================================================================
    # 1. LEER DATOS
    # =========================================================================
    print("1. Leyendo archivos...")
    
    # Archivo de código MATLAB
    if not os.path.exists('N_axial_codigo.csv'):
        print("❌ ERROR: No se encontró 'N_axial_codigo.csv'")
        print("   Ejecuta primero: main_comparacion_etabs.m en MATLAB")
        return
    
    df_codigo = pd.read_csv('N_axial_codigo.csv')
    print(f"   ✓ Código MATLAB: {len(df_codigo)} elementos")
    
    # Archivo de ETABS
    etabs_path = '001_runExperimentos/003_funcion_deformaciones/P_etabs_promedio.csv'
    if not os.path.exists(etabs_path):
        print(f"❌ ERROR: No se encontró '{etabs_path}'")
        print("   Verifica que el archivo de ETABS esté en la ubicación correcta")
        return
    
    df_etabs = pd.read_csv(etabs_path)
    print(f"   ✓ ETABS: {len(df_etabs)} elementos")
    print()
    
    # =========================================================================
    # 2. UNIR DATOS
    # =========================================================================
    print("2. Procesando datos...")
    
    # Merge por número de elemento
    df = pd.merge(
        df_codigo, 
        df_etabs, 
        left_on='Elemento', 
        right_on='Elemento',
        how='inner'
    )
    
    print(f"   ✓ Elementos comunes: {len(df)}")
    
    # Calcular diferencias
    df['Diff_kN'] = df['N_axial_kN'] - df['P_promedio_kN']
    df['Diff_abs_kN'] = np.abs(df['Diff_kN'])
    
    # Porcentaje de diferencia respecto a ETABS
    # Evitar división por cero
    epsilon = 1e-6
    df['Diff_pct'] = 100 * df['Diff_abs_kN'] / (np.abs(df['P_promedio_kN']) + epsilon)
    
    # Clasificar elementos
    df['Tipo'] = 'Compresión'
    df.loc[df['P_promedio_kN'] > 0, 'Tipo'] = 'Tensión'
    
    print()
    
    # =========================================================================
    # 3. ESTADÍSTICAS GLOBALES
    # =========================================================================
    print("=" * 80)
    print("  ESTADÍSTICAS DE COMPARACIÓN")
    print("=" * 80)
    print()
    
    # Filtrar elementos con carga significativa (|P| > 10 kN)
    df_sig = df[np.abs(df['P_promedio_kN']) > 10].copy()
    
    print(f"Elementos analizados: {len(df_sig)} (excluyendo |P| < 10 kN)")
    print()
    
    # Diferencia promedio
    diff_mean = df_sig['Diff_abs_kN'].mean()
    diff_std = df_sig['Diff_abs_kN'].std()
    diff_pct_mean = df_sig['Diff_pct'].mean()
    diff_pct_std = df_sig['Diff_pct'].std()
    
    print(f"Diferencia absoluta:")
    print(f"  Media:       {diff_mean:8.2f} kN")
    print(f"  Desv. Est.:  {diff_std:8.2f} kN")
    print(f"  Máxima:      {df_sig['Diff_abs_kN'].max():8.2f} kN (elemento {df_sig.loc[df_sig['Diff_abs_kN'].idxmax(), 'Elemento']:.0f})")
    print(f"  Mínima:      {df_sig['Diff_abs_kN'].min():8.2f} kN (elemento {df_sig.loc[df_sig['Diff_abs_kN'].idxmin(), 'Elemento']:.0f})")
    print()
    
    print(f"Diferencia porcentual:")
    print(f"  Media:       {diff_pct_mean:7.2f} %")
    print(f"  Desv. Est.:  {diff_pct_std:7.2f} %")
    print(f"  Máxima:      {df_sig['Diff_pct'].max():7.2f} % (elemento {df_sig.loc[df_sig['Diff_pct'].idxmax(), 'Elemento']:.0f})")
    print(f"  Mínima:      {df_sig['Diff_pct'].min():7.2f} % (elemento {df_sig.loc[df_sig['Diff_pct'].idxmin(), 'Elemento']:.0f})")
    print()
    
    # =========================================================================
    # 4. ELEMENTOS CON MAYOR DIFERENCIA
    # =========================================================================
    print("=" * 80)
    print("  TOP 10 ELEMENTOS CON MAYOR DIFERENCIA")
    print("=" * 80)
    print()
    
    df_top = df_sig.nlargest(10, 'Diff_abs_kN')[['Elemento', 'N_axial_kN', 'P_promedio_kN', 'Diff_kN', 'Diff_pct', 'Tipo']]
    
    print(f"{'Elem':>6} {'Código(kN)':>12} {'ETABS(kN)':>12} {'Diff(kN)':>11} {'Diff(%)':>9} {'Tipo':>12}")
    print("-" * 70)
    for _, row in df_top.iterrows():
        print(f"{row['Elemento']:6.0f} {row['N_axial_kN']:12.2f} {row['P_promedio_kN']:12.2f} "
              f"{row['Diff_kN']:11.2f} {row['Diff_pct']:9.2f} {row['Tipo']:>12}")
    print()
    
    # =========================================================================
    # 5. ANÁLISIS POR TIPO DE ELEMENTO
    # =========================================================================
    print("=" * 80)
    print("  ANÁLISIS POR TIPO DE ELEMENTO")
    print("=" * 80)
    print()
    
    for tipo in ['Compresión', 'Tensión']:
        df_tipo = df_sig[df_sig['Tipo'] == tipo]
        if len(df_tipo) > 0:
            print(f"{tipo}:")
            print(f"  Elementos: {len(df_tipo)}")
            print(f"  Diff media: {df_tipo['Diff_abs_kN'].mean():.2f} kN ({df_tipo['Diff_pct'].mean():.2f} %)")
            print(f"  Diff máxima: {df_tipo['Diff_abs_kN'].max():.2f} kN ({df_tipo['Diff_pct'].max():.2f} %)")
            print()
    
    # =========================================================================
    # 6. EVALUACIÓN DE CALIDAD
    # =========================================================================
    print("=" * 80)
    print("  EVALUACIÓN DE CALIDAD")
    print("=" * 80)
    print()
    
    # Contar elementos por rango de error
    n_excelente = len(df_sig[df_sig['Diff_pct'] < 1.0])
    n_muy_bueno = len(df_sig[(df_sig['Diff_pct'] >= 1.0) & (df_sig['Diff_pct'] < 2.0)])
    n_bueno = len(df_sig[(df_sig['Diff_pct'] >= 2.0) & (df_sig['Diff_pct'] < 5.0)])
    n_aceptable = len(df_sig[(df_sig['Diff_pct'] >= 5.0) & (df_sig['Diff_pct'] < 10.0)])
    n_malo = len(df_sig[df_sig['Diff_pct'] >= 10.0])
    
    print(f"Distribución de error:")
    print(f"  Excelente (< 1%):      {n_excelente:4d} elementos ({100*n_excelente/len(df_sig):5.1f}%)")
    print(f"  Muy bueno (1-2%):      {n_muy_bueno:4d} elementos ({100*n_muy_bueno/len(df_sig):5.1f}%)")
    print(f"  Bueno (2-5%):          {n_bueno:4d} elementos ({100*n_bueno/len(df_sig):5.1f}%)")
    print(f"  Aceptable (5-10%):     {n_aceptable:4d} elementos ({100*n_aceptable/len(df_sig):5.1f}%)")
    print(f"  Malo (> 10%):          {n_malo:4d} elementos ({100*n_malo/len(df_sig):5.1f}%)")
    print()
    
    # Veredicto
    if diff_pct_mean < 2.0:
        calificacion = "✓ EXCELENTE"
        mensaje = "Las fuerzas axiales coinciden muy bien con ETABS."
    elif diff_pct_mean < 5.0:
        calificacion = "✓ MUY BUENO"
        mensaje = "Las fuerzas axiales coinciden bien con ETABS."
    elif diff_pct_mean < 10.0:
        calificacion = "⚠ BUENO"
        mensaje = "Las fuerzas axiales tienen diferencias moderadas con ETABS."
    else:
        calificacion = "✗ REQUIERE REVISIÓN"
        mensaje = "Las fuerzas axiales tienen diferencias significativas con ETABS."
    
    print(f"VEREDICTO: {calificacion}")
    print(f"  {mensaje}")
    print()
    
    if diff_pct_mean < 5.0:
        print("  → El problema con ρ > 1.0 está en el cálculo de Pcr (factor K)")
        print("    Recomendación: Implementar K = 0.65-0.80 según tipo de elemento")
    else:
        print("  → Revisar cálculo de N_axial (transformaciones, ensamblaje)")
    
    print()
    
    # =========================================================================
    # 7. GUARDAR RESULTADOS
    # =========================================================================
    print("=" * 80)
    print("  GUARDANDO RESULTADOS")
    print("=" * 80)
    print()
    
    # Tabla completa
    df_export = df[['Elemento', 'N_axial_kN', 'P_promedio_kN', 'Diff_kN', 
                    'Diff_abs_kN', 'Diff_pct', 'Tipo']].copy()
    df_export = df_export.sort_values('Diff_abs_kN', ascending=False)
    df_export.to_csv('comparacion_resultados.csv', index=False)
    print("  ✓ Tabla comparativa: comparacion_resultados.csv")
    
    # Resumen estadístico
    with open('comparacion_estadisticas.txt', 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("  ESTADÍSTICAS DE COMPARACIÓN: CÓDIGO MATLAB vs ETABS\n")
        f.write("=" * 80 + "\n\n")
        f.write(f"Elementos analizados: {len(df_sig)}\n\n")
        f.write(f"Diferencia absoluta:\n")
        f.write(f"  Media:       {diff_mean:8.2f} kN\n")
        f.write(f"  Desv. Est.:  {diff_std:8.2f} kN\n\n")
        f.write(f"Diferencia porcentual:\n")
        f.write(f"  Media:       {diff_pct_mean:7.2f} %\n")
        f.write(f"  Desv. Est.:  {diff_pct_std:7.2f} %\n\n")
        f.write(f"VEREDICTO: {calificacion}\n")
        f.write(f"  {mensaje}\n")
    
    print("  ✓ Resumen estadístico: comparacion_estadisticas.txt")
    print()
    
    print("=" * 80)
    print("  COMPARACIÓN COMPLETADA")
    print("=" * 80)
    print()

if __name__ == "__main__":
    main()

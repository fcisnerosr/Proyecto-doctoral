import pandas as pd
import numpy as np

# Leer CSV de ETABS
df = pd.read_csv('001_runExperimentos/003_funcion_deformaciones/carga_axial_ETABS.csv')

# Promediar los 3 valores por elemento
elementos = df['Element'].unique()
P_etabs = {}
for elem in elementos:
    valores = df[df['Element'] == elem]['P_kN'].values
    P_etabs[elem] = np.mean(valores)

# Mostrar estadísticas
print("="*70)
print("ANÁLISIS DE CARGAS AXIALES DE ETABS")
print("="*70)
print(f"\nTotal de elementos: {len(P_etabs)}")
print(f"\nCarga axial promedio: {np.mean(list(P_etabs.values())):.2f} kN")
print(f"Carga axial máxima: {np.max(list(P_etabs.values())):.2f} kN (elemento {max(P_etabs, key=P_etabs.get)})")
print(f"Carga axial mínima: {np.min(list(P_etabs.values())):.2f} kN (elemento {min(P_etabs, key=P_etabs.get)})")

# Elementos de interés (que pasaron el filtro según tu output)
elementos_interes = [3, 15, 25, 29, 37, 40, 76, 84, 117, 119]

print("\n" + "="*70)
print("ELEMENTOS QUE PASARON EL FILTRO (rho ∈ [0.20, 0.75])")
print("="*70)
print(f"\n{'Elem':>6} {'P_ETABS(kN)':>15} {'|P|(kN)':>12}")
print("-"*40)
for elem in elementos_interes:
    if elem in P_etabs:
        print(f"{elem:6d} {P_etabs[elem]:15.2f} {abs(P_etabs[elem]):12.2f}")

# Análisis de elementos más cargados
print("\n" + "="*70)
print("TOP 15 ELEMENTOS MÁS CARGADOS (COMPRESIÓN)")
print("="*70)
P_sorted = sorted(P_etabs.items(), key=lambda x: x[1])
print(f"\n{'Elem':>6} {'P(kN)':>12} {'|P|(kN)':>12}")
print("-"*35)
for elem, P in P_sorted[:15]:
    print(f"{elem:6d} {P:12.2f} {abs(P):12.2f}")

# Elementos en tensión
P_tension = {k: v for k, v in P_etabs.items() if v > 0}
print("\n" + "="*70)
print(f"ELEMENTOS EN TENSIÓN (P > 0): {len(P_tension)}")
print("="*70)
if len(P_tension) > 0:
    print(f"\n{'Elem':>6} {'P(kN)':>12}")
    print("-"*22)
    for elem, P in sorted(P_tension.items(), key=lambda x: -x[1])[:10]:
        print(f"{elem:6d} {P:12.2f}")

# Elementos en compresión severa (|P| > 5000 kN)
P_compresion_severa = {k: v for k, v in P_etabs.items() if v < -5000}
print("\n" + "="*70)
print(f"ELEMENTOS EN COMPRESIÓN SEVERA (|P| > 5000 kN): {len(P_compresion_severa)}")
print("="*70)

# Guardar para análisis posterior
df_processed = pd.DataFrame(list(P_etabs.items()), columns=['Elemento', 'P_promedio_kN'])
df_processed = df_processed.sort_values('Elemento')
df_processed.to_csv('001_runExperimentos/003_funcion_deformaciones/P_etabs_promedio.csv', index=False)
print(f"\n✓ Datos guardados en: P_etabs_promedio.csv")

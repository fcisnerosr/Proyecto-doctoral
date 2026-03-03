#!/usr/bin/env python3
import pandas as pd

# Leer archivo remapeado final
df = pd.read_excel('todos_los_resultados_remapeado_final.xlsx')

print("="*70)
print("VERIFICACIÓN DE REMAPEO - ABOLLADURAS 2026")
print("="*70)

# Estadísticas básicas
print(f"\n📊 Dataset:")
print(f"   Dimensiones: {df.shape}")

# Distribución de DeteccionOK
print(f"\n📊 Distribución de DeteccionOK:")
dist = df['DeteccionOK'].value_counts().sort_index()
for valor, count in dist.items():
    pct = 100 * count / len(df)
    if valor == 0:
        label = "Fallo completo"
    elif valor == 0.5:
        label = "✅ REMAPEADO (detección indirecta)"
    elif valor == 1:
        label = "Detección directa"
    else:
        label = "Valor inesperado"
    print(f"   {valor}: {count:>4} ({pct:>5.1f}%) - {label}")

# Total remapeados
n_remapeados = (df['DeteccionOK'] == 0.5).sum()
print(f"\n✅ Total casos remapeados (0→0.5): {n_remapeados}")

if n_remapeados > 0:
    print(f"\n📋 Ejemplos de casos remapeados (primeros 5):")
    remapeados = df[df['DeteccionOK'] == 0.5].head(5)
    print(remapeados[['ID', 'Elemento', 'Porcentaje', 'DeteccionOK', 'N_FalsosPositivos']].to_string(index=False))
    
    print(f"\n📊 Análisis de remapeados:")
    print(f"   Total remapeados: {n_remapeados}")
    print(f"   Porcentaje de remapeados: {100*n_remapeados/len(df):.1f}%")
    
    # Por elemento
    if 'Tipo_elemento_a_buscar' in df.columns:
        print(f"\n📊 Remapeados por tipo de elemento:")
        remapeados_full = df[df['DeteccionOK'] == 0.5]
        dist_tipo = remapeados_full['Tipo_elemento_a_buscar'].value_counts()
        print(dist_tipo)
else:
    print("\n⚠️  NO se encontraron casos remapeados")
    print("   Posibles razones:")
    print("   - El remapeo no se ejecutó")
    print("   - Todos los beams/legs ya tenían DeteccionOK=1")

print("\n" + "="*70)

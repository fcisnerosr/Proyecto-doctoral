#!/usr/bin/env python3
"""
Script para mapear Story 1-5 a nombres de zonas (mudline, sub1, sub2, sub3, splash)
en el CSV de corrosión.

Mapeo:
- Story 1 → mudline (nivel más bajo)
- Story 2 → sub1 (sobre mudline)
- Story 3 → sub2 (nivel medio)
- Story 4 → sub3 (debajo de splash)
- Story 5 → splash (nivel del mar)
"""

import pandas as pd
import shutil
from pathlib import Path

# Rutas
csv_path = Path("~/proyecto-doctoral/Resultados/resultados_corrosion_JSV/jupyter_notebooks/todos_los_resultados_csv_remapeado_final.csv").expanduser()
backup_path = csv_path.with_suffix('.csv.backup_before_story_mapping')

# Crear backup
print(f"Creando backup en: {backup_path}")
shutil.copy2(csv_path, backup_path)

# Cargar CSV
print(f"Cargando CSV: {csv_path}")
df = pd.read_csv(csv_path)

print(f"Total de filas: {len(df)}")
print(f"Columnas: {df.columns.tolist()}")
print(f"\nValores únicos en Story ANTES del mapeo:")
print(df['Story'].value_counts().sort_index())

# Mapeo de Story a zonas
story_to_zone = {
    'Story 1': 'mudline',
    'Story 2': 'sub1',
    'Story 3': 'sub2',
    'Story 4': 'sub3',
    'Story 5': 'splash'
}

# Aplicar mapeo
df['Story'] = df['Story'].map(story_to_zone)

print(f"\nValores únicos en Story DESPUÉS del mapeo:")
print(df['Story'].value_counts().sort_index())

# Verificar que no hay valores NaN después del mapeo
if df['Story'].isna().any():
    print(f"\n⚠️ ADVERTENCIA: Se encontraron {df['Story'].isna().sum()} valores NaN después del mapeo")
    print("Valores originales que no fueron mapeados:")
    df_original = pd.read_csv(backup_path)
    unmapped = df_original.loc[df['Story'].isna(), 'Story'].unique()
    print(unmapped)
else:
    print("\n✓ Todos los valores fueron mapeados correctamente")

# Guardar CSV con el mapeo
print(f"\nGuardando CSV modificado en: {csv_path}")
df.to_csv(csv_path, index=False)

print("\n✓ Proceso completado exitosamente")
print(f"✓ Backup guardado en: {backup_path}")

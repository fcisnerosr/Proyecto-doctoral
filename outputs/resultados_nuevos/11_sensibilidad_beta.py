"""
Análisis de sensibilidad del parámetro beta del factor de penalización P_FP del DQI,
y verificación de la calibración topológica beta = 1/n_bar_1.

Respalda las afirmaciones añadidas al manuscrito (Sección 4.3.3):
  - beta = 0.15 cae en la banda topológica [1/n1_BFS, 1/z_bar] = [0.13, 0.19]
  - El ranking de detectabilidad Brace > Inclined_leg > Beam es invariante a beta
  - El umbral de detección confiable de braces (DQI>0.7) se mantiene en ~30-35%

Uso:  python 11_sensibilidad_beta.py
"""
import pandas as pd
import numpy as np
from collections import defaultdict
from pathlib import Path

BASE = Path(__file__).resolve().parents[2]
RES = BASE / 'outputs' / 'resultados_nuevos'
MODELO = (BASE / 'data' / 'pruebas_excel' / 'ETABS_modelo' / 'ETABS' /
          'revision_6_jacket-subestructura_4NIVELES' /
          'datos_revision_5_jacket-subestructura_5NIVELES.xlsx')

# ── 1. Descriptores topológicos del modelo (calibración de beta) ──────────────
def cargar_hoja(sheet):
    df = pd.read_excel(MODELO, sheet_name=sheet, header=1)
    return df.drop(0).reset_index(drop=True)

edges = []
for s in ['Beam Object Connectivity', 'Brace Object Connectivity',
          'Column Object Connectivity']:
    for _, r in cargar_hoja(s).iterrows():
        try:
            edges.append((int(r['UniquePtI']), int(r['UniquePtJ'])))
        except (ValueError, TypeError):
            pass

g = defaultdict(set)
for i, j in edges:
    g[i].add(j)
    g[j].add(i)
nodos = sorted(g)
EMPOTRADOS = {1, 2, 3, 4}

z_bar = np.mean([len(g[n]) for n in nodos])
veci_bfs = []
for i, j in edges:
    veci_bfs.append(len((g[i] | g[j]) - {i, j} - EMPOTRADOS))
n1_bfs = np.mean(veci_bfs)

beta_lo, beta_hi = 1 / n1_bfs, 1 / z_bar
print('=' * 70)
print('CALIBRACIÓN TOPOLÓGICA DE beta')
print('=' * 70)
print(f'Nodos estructurales: {len(nodos)}  (libres tras quitar 4 apoyos: {len(nodos)-4})')
print(f'Grado nodal medio  z_bar      = {z_bar:.2f}  -> 1/z_bar = {1/z_bar:.3f}')
print(f'Vecindario BFS d=1 n1_bfs     = {n1_bfs:.2f}  -> 1/n1   = {1/n1_bfs:.3f}')
print(f'Banda topológica admisible    = [{beta_lo:.3f}, {beta_hi:.3f}]')
print(f'Punto medio (beta adoptado)   = {(beta_lo+beta_hi)/2:.3f}')
print(f'Vida media de confianza @0.15 = ln(2)/0.15 = {np.log(2)/0.15:.2f} FP')

# ── 2. Sensibilidad de las conclusiones al valor de beta ──────────────────────
cat = pd.read_csv(RES / 'elements_catalog.csv')[['element_id', 'Design_Type']]

def cargar_resultados(fname, pmax):
    df = pd.read_excel(fname).merge(cat, left_on='Elemento', right_on='element_id')
    df['Cnorm'] = np.log(1 + 0.1 * df['Porcentaje']) / np.log(1 + 0.1 * pmax)
    return df

den = cargar_resultados(RES / 'abolladuras_2026' / 'todos_los_resultados_remapeado_final.xlsx', 45)
cor = cargar_resultados(RES / 'corrosion_2026' / 'todos_los_resultados_remapeado_final.xlsx', 90)

def dqi(df, beta):
    return df['DeteccionOK'] * df['Cnorm'] * np.exp(-beta * df['N_FalsosPositivos'])

print('\n' + '=' * 70)
print('SENSIBILIDAD: % de casos con DQI>0.7 por tipo (severidad >= 30%)')
print('=' * 70)
for name, df in [('DENTING', den), ('CORROSION', cor)]:
    print(f'\n{name}')
    print(f"{'beta':>6} | {'Brace':>7} {'Incl.Leg':>9} {'Beam':>6} | ranking OK")
    sub = df[df['Porcentaje'] >= 30]
    for beta in [0.05, 0.10, 0.15, 0.20, 0.25]:
        d = dqi(sub, beta)
        rate = {t: (d[sub['Design_Type'] == t] > 0.7).mean() * 100
                for t in ['Brace', 'Inclined_leg', 'Beam']}
        ok = rate['Brace'] >= rate['Inclined_leg'] >= rate['Beam']
        star = '  <- adoptado' if beta == 0.15 else ''
        print(f"{beta:>6.2f} | {rate['Brace']:>6.1f}% {rate['Inclined_leg']:>8.1f}% "
              f"{rate['Beam']:>5.1f}% | {'si' if ok else 'NO'}{star}")

print('\n' + '=' * 70)
print('Severidad de cruce DQI_medio(Brace) > 0.7 vs beta (denting)')
print('=' * 70)
for beta in [0.05, 0.10, 0.15, 0.20, 0.25]:
    den['DQI'] = dqi(den, beta)
    m = den[den['Design_Type'] == 'Brace'].groupby('Porcentaje')['DQI'].mean()
    cruce = m[m > 0.7]
    print(f'  beta={beta:.2f}: cruza a {cruce.index.min() if len(cruce) else "n/a"}%')

import pandas as pd
import numpy as np

# Leer datos promediados de ETABS
df_etabs = pd.read_csv('001_runExperimentos/003_funcion_deformaciones/P_etabs_promedio.csv')
P_etabs = dict(zip(df_etabs['Elemento'], df_etabs['P_promedio_kN']))

# Elementos que pasaron el filtro según tu output anterior
elementos_filtrados = [3, 15, 25, 29, 37, 40, 76, 84]

# Propiedades geométricas típicas (valores aproximados de una jacket offshore)
# Asumiendo que estos elementos son diagonales/bracing
E = 200000  # MPa = 200 GPa
D_typical = 0.5  # metros (diámetro típico de brace)
t_typical = 0.020  # metros (espesor típico 20mm)
L_typical = 15  # metros (longitud típica entre niveles)

# Cálculo de propiedades geométricas (tubo circular)
D = D_typical
t = t_typical
R_ext = D / 2
R_int = R_ext - t
A = np.pi * (R_ext**2 - R_int**2)  # m²
I = np.pi * (R_ext**4 - R_int**4) / 4  # m⁴

# Cálculo de Pcr con K=1.0 (pinned-pinned, como en tu código)
K = 1.0
E_Pa = E * 1e6  # Convertir MPa a Pa
Pcr_N = (np.pi**2 * E_Pa * I) / (K * L_typical)**2  # Newton
Pcr_kN = Pcr_N / 1000

print("="*80)
print("ANÁLISIS TEÓRICO: COMPARACIÓN ETABS vs MI CÓDIGO")
print("="*80)
print(f"\nPropiedades asumidas (típicas de jacket offshore):")
print(f"  Diámetro: {D*1000:.0f} mm")
print(f"  Espesor: {t*1000:.0f} mm")
print(f"  Longitud: {L_typical:.1f} m")
print(f"  Área: {A*1e4:.2f} cm²")
print(f"  Inercia: {I*1e8:.2f} cm⁴")
print(f"  E: {E:.0f} MPa")
print(f"  K: {K:.2f} (pinned-pinned)")
print(f"\n  → Pcr = {Pcr_kN:.2f} kN")

print("\n" + "="*80)
print("ELEMENTOS FILTRADOS (rho ∈ [0.20, 0.75])")
print("="*80)
print(f"\n{'Elem':>6} {'|P_ETABS|':>12} {'Pcr_teorica':>14} {'rho_teorico':>14}")
print(f"{'':>6} {'(kN)':>12} {'(kN)':>14} {'':>14}")
print("-"*52)

rho_teoricos = []
for elem in elementos_filtrados:
    if elem in P_etabs:
        P_abs = abs(P_etabs[elem])
        rho_teorico = P_abs / Pcr_kN
        rho_teoricos.append(rho_teorico)
        print(f"{elem:6d} {P_abs:12.2f} {Pcr_kN:14.2f} {rho_teorico:14.3f}")

print("\n" + "="*80)
print("ANÁLISIS DE RESULTADOS")
print("="*80)

print(f"\nRango de rho teórico: [{min(rho_teoricos):.3f}, {max(rho_teoricos):.3f}]")
print(f"Promedio rho teórico: {np.mean(rho_teoricos):.3f}")

# Calcular Pcr necesario para que rho esté en [0.20, 0.75]
print("\n" + "-"*80)
print("Para el elemento más cargado (25 o 40): |P| = 6362.98 kN")
print("-"*80)

P_max = 6362.98
rho_target = 0.75  # máximo permitido
Pcr_necesario = P_max / rho_target

print(f"\nPara tener rho = {rho_target:.2f}:")
print(f"  Pcr necesario = {Pcr_necesario:.2f} kN")
print(f"  Pcr actual (K=1.0) = {Pcr_kN:.2f} kN")
print(f"  → Pcr es {Pcr_kN/Pcr_necesario:.3f}× el valor necesario")
print(f"  → rho real = {P_max/Pcr_kN:.3f} (FÍSICAMENTE IMPOSIBLE si > 1.0)")

# Calcular K necesario
if Pcr_kN < Pcr_necesario:
    # Necesitamos reducir K para aumentar Pcr
    # Pcr = π²EI/(KL)², entonces K = sqrt(π²EI/(Pcr*L²))
    K_necesario = np.sqrt((np.pi**2 * E_Pa * I) / (Pcr_necesario * 1000 * L_typical**2))
    print(f"\n  Para lograr rho ≤ 0.75:")
    print(f"    K necesario = {K_necesario:.3f}")
    print(f"    Esto correspondería a extremos más restringidos")

print("\n" + "="*80)
print("CONCLUSIÓN PRELIMINAR")
print("="*80)

if max(rho_teoricos) > 1.0:
    print("\n⚠️  PROBLEMA DETECTADO:")
    print(f"   - rho máximo teórico = {max(rho_teoricos):.2f} > 1.0")
    print("   - Esto significa que el elemento YA HABRÍA PANDEAD O")
    print()
    print("   Posibles causas:")
    print("   1. K=1.0 es muy conservador (debería ser K≈0.5-0.8 para jackets)")
    print("   2. Las propiedades geométricas asumidas son incorrectas")
    print("   3. La longitud efectiva es menor que la longitud del elemento")
    print()
    print("   → NECESITO: Ejecutar tu código para obtener los valores reales de")
    print("              N_axial, Pcr, longitud, inercia de cada elemento")
else:
    print("\n✓ Los valores teóricos están en rango aceptable")
    print("  → Las fuerzas axiales de ETABS son consistentes con rho < 1.0")


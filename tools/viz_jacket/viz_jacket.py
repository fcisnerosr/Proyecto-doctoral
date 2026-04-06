"""
viz_jacket.py — Visualizador 3D interactivo de estructura Jacket Offshore
==========================================================================
Fuente de datos: ETABS (exportado a Excel).

Uso:
    python viz_jacket.py           # genera jacket_3d.html en esta carpeta
    python viz_jacket.py --serve   # genera HTML y abre servidor local en :8050

Salida: tools/viz_jacket/jacket_3d.html  (standalone, no requiere servidor)
"""

import sys
import argparse
from pathlib import Path

import pandas as pd
import numpy as np
import plotly.graph_objects as go

# ─── RUTAS ────────────────────────────────────────────────────────────────────
REPO_ROOT = Path(__file__).resolve().parents[2]
EXCEL_PATH = (
    REPO_ROOT
    / "pruebas_excel"
    / "ETABS_modelo"
    / "ETABS"
    / "revision_6_jacket-subestructura_4NIVELES"
    / "datos_revision_5_jacket-subestructura_5NIVELES.xlsx"
)
OUT_HTML = Path(__file__).parent / "jacket_3d.html"

# mm → m  (todas las coordenadas del ETABS están en mm)
SCALE = 1.0 / 1000.0

# ─── PALETA ───────────────────────────────────────────────────────────────────
CLR = {
    "Beam":   "#2980B9",   # azul
    "Brace":  "#E67E22",   # naranja
    "Column": "#E74C3C",   # rojo
}
NODE_DEFAULT   = "#2ECC71"   # verde — nodo libre
NODE_RESTRAINED = "#C0392B"  # rojo oscuro — empotrado


# ─── CARGA DE DATOS ───────────────────────────────────────────────────────────

def load_excel(path: Path) -> dict:
    """Lee las hojas necesarias del Excel de ETABS y devuelve DataFrames limpios."""
    xl = pd.ExcelFile(path)

    # --- Nodos (coordenadas) ---
    # Hoja "Assembled Joint Masses": Story | Label | Point | UX..RZ | X | Y | Z
    nodos = xl.parse("Assembled Joint Masses", skiprows=2)
    nodos.columns = ["Story", "Label", "Point", "UX", "UY", "UZ",
                     "RX", "RY", "RZ", "X", "Y", "Z"]
    nodos = nodos[["Story", "Label", "Point", "X", "Y", "Z"]].copy()
    nodos[["X", "Y", "Z"]] = nodos[["X", "Y", "Z"]].astype(float) * SCALE
    nodos["Point"] = nodos["Point"].astype(int)
    nodos["Label"] = nodos["Label"].astype(int)

    # --- Nodos empotrados ---
    rest = xl.parse("Joint Assigns - Restraints", skiprows=2)
    rest.columns = ["Story", "Label", "UniqueName", "UX", "UY", "UZ", "RX", "RY", "RZ"]
    # UniqueName en restricciones = Point en nodos
    restrained_points = set(rest["UniqueName"].astype(int).tolist())

    # --- Sección por elemento ---
    sect = xl.parse("Frame Assigns - Sect Prop", skiprows=2)
    sect.columns = ["Story", "Label", "UniqueName", "Shape", "AutoSelect", "Section"]
    sect_dict = dict(zip(sect["UniqueName"].astype(int), sect["Section"].astype(str)))

    # --- Propiedades de sección (diámetro exterior) ---
    sec_def = xl.parse("Frame Sec Def - Steel Pipe", skiprows=2)
    sec_def.columns = ["Name", "Material", "FromFile", "OD", "WT",
                       "AreaMod", "As2Mod", "As3Mod", "JMod", "I22Mod", "I33Mod",
                       "MassMod", "WeightMod", "Color", "GUID", "Notes"]
    sec_props = {}
    for _, row in sec_def.iterrows():
        sec_props[str(row["Name"])] = {
            "OD_mm": float(row["OD"]),
            "WT_mm": float(row["WT"]),
        }

    # --- Conectividad ---
    def _conn(sheet, bay_col):
        df = xl.parse(sheet, skiprows=2)
        df.columns = ["UniqueName", "Story", bay_col, "UniquePtI", "UniquePtJ", "Length", "GUID"]
        df["UniqueName"] = df["UniqueName"].astype(int)
        df["UniquePtI"]  = df["UniquePtI"].astype(int)
        df["UniquePtJ"]  = df["UniquePtJ"].astype(int)
        return df[["UniqueName", "UniquePtI", "UniquePtJ"]].copy()

    elements = {
        "Beam":   _conn("Beam Object Connectivity",   "BeamBay"),
        "Brace":  _conn("Brace Object Connectivity",  "BraceBay"),
        "Column": _conn("Column Object Connectivity", "ColumnBay"),
    }

    return {
        "nodos": nodos,
        "restrained_points": restrained_points,
        "sect_dict": sect_dict,
        "sec_props": sec_props,
        "elements": elements,
    }


# ─── CONSTRUCCIÓN DE FIGURA ───────────────────────────────────────────────────

def build_figure(data: dict) -> go.Figure:
    nodos             = data["nodos"]
    restrained_points = data["restrained_points"]
    sect_dict         = data["sect_dict"]
    sec_props         = data["sec_props"]
    elements          = data["elements"]

    # Índice rápido Point → (X, Y, Z)
    node_xyz = nodos.set_index("Point")[["X", "Y", "Z"]].to_dict("index")

    def xyz(pt):
        n = node_xyz[pt]
        return n["X"], n["Y"], n["Z"]

    fig = go.Figure()

    # ── 1. Elementos (líneas) ─────────────────────────────────────────────────
    line_widths = {"Beam": 3, "Brace": 2, "Column": 5}

    for etype, df in elements.items():
        # Traza de líneas
        xs, ys, zs = [], [], []
        for _, row in df.iterrows():
            try:
                xi, yi, zi = xyz(row["UniquePtI"])
                xj, yj, zj = xyz(row["UniquePtJ"])
            except KeyError:
                continue
            xs += [xi, xj, None]
            ys += [yi, yj, None]
            zs += [zi, zj, None]

        fig.add_trace(go.Scatter3d(
            x=xs, y=ys, z=zs,
            mode="lines",
            line=dict(color=CLR[etype], width=line_widths[etype]),
            name=etype,
            legendgroup=etype,
            hoverinfo="skip",
        ))

        # Puntos invisibles en el centroide de cada elemento para tooltips
        mx, my, mz, htexts, elem_labels = [], [], [], [], []
        for _, row in df.iterrows():
            try:
                xi, yi, zi = xyz(row["UniquePtI"])
                xj, yj, zj = xyz(row["UniquePtJ"])
            except KeyError:
                continue
            sec = sect_dict.get(row["UniqueName"], "?")
            sp  = sec_props.get(sec, {})
            od  = sp.get("OD_mm", "?")
            wt  = sp.get("WT_mm", "?")

            mx.append((xi + xj) / 2)
            my.append((yi + yj) / 2)
            mz.append((zi + zj) / 2)
            elem_labels.append(str(row["UniqueName"]))
            htexts.append(
                f"<b>Elemento {row['UniqueName']}</b><br>"
                f"Tipo: {etype}<br>"
                f"Sección: {sec}  (OD={od} mm, t={wt} mm)<br>"
                f"Nodo I: {row['UniquePtI']}  →  Nodo J: {row['UniquePtJ']}<br>"
                f"X_mid: {(xi+xj)/2:.2f} m  "
                f"Y_mid: {(yi+yj)/2:.2f} m  "
                f"Z_mid: {(zi+zj)/2:.2f} m"
            )

        # Etiquetas de número de elemento + hover en centroide
        fig.add_trace(go.Scatter3d(
            x=mx, y=my, z=mz,
            mode="markers+text",
            marker=dict(size=4, color=CLR[etype], opacity=0.55,
                        line=dict(width=0)),
            text=elem_labels,
            textposition="middle center",
            textfont=dict(size=10, color="#FFFFFF", family="monospace"),
            hovertext=htexts,
            hoverinfo="text",
            name=f"Núm. {etype}",
            legendgroup=etype,
            showlegend=True,
        ))

    # ── 2. Nodos ──────────────────────────────────────────────────────────────
    node_colors  = []
    node_symbols = []
    hover_nodes  = []

    for _, row in nodos.iterrows():
        pt = int(row["Point"])
        es_base = (pt in restrained_points)
        node_colors.append(NODE_RESTRAINED if es_base else NODE_DEFAULT)
        node_symbols.append("square" if es_base else "circle")
        hover_nodes.append(
            f"<b>Nodo {pt}</b><br>"
            f"Label ETABS: {int(row['Label'])}<br>"
            f"Nivel: {row['Story']}<br>"
            f"X: {row['X']:.3f} m<br>"
            f"Y: {row['Y']:.3f} m<br>"
            f"Z: {row['Z']:.3f} m"
            + ("<br><b>⚑ EMPOTRADO (base)</b>" if es_base else "")
        )

    fig.add_trace(go.Scatter3d(
        x=nodos["X"].tolist(),
        y=nodos["Y"].tolist(),
        z=nodos["Z"].tolist(),
        mode="markers+text",
        marker=dict(
            size=5,
            color=node_colors,
            symbol=node_symbols,
            line=dict(width=1, color="white"),
        ),
        text=[str(int(p)) for p in nodos["Point"]],
        textposition="top center",
        textfont=dict(size=8, color="#ECF0F1"),
        hovertext=hover_nodes,
        hoverinfo="text",
        name="Nodos",
        legendgroup="Nodos",
    ))

    # ── 3. Layout ─────────────────────────────────────────────────────────────
    n_beam   = len(elements["Beam"])
    n_brace  = len(elements["Brace"])
    n_column = len(elements["Column"])
    n_nodos  = len(nodos)

    fig.update_layout(
        title=dict(
            text=(
                "Estructura Jacket Offshore — Modelo ETABS<br>"
                f"<sup>{n_nodos} nodos · "
                f"{n_beam} vigas (Beam) · "
                f"{n_brace} diagonales (Brace) · "
                f"{n_column} columnas (Column) | "
                "Hover → info · Doble-clic leyenda → aislar tipo</sup>"
            ),
            x=0.5,
            font=dict(size=14),
        ),
        scene=dict(
            xaxis_title="X [m]",
            yaxis_title="Y [m]",
            zaxis_title="Z [m] (elevación)",
            aspectmode="data",
            bgcolor="#12132a",
            xaxis=dict(
                color="#AAB7B8",
                gridcolor="#2C3E50",
                showbackground=True,
                backgroundcolor="#0d0e20",
            ),
            yaxis=dict(
                color="#AAB7B8",
                gridcolor="#2C3E50",
                showbackground=True,
                backgroundcolor="#0d0e20",
            ),
            zaxis=dict(
                color="#AAB7B8",
                gridcolor="#2C3E50",
                showbackground=True,
                backgroundcolor="#0d0e20",
            ),
            camera=dict(
                eye=dict(x=1.6, y=1.6, z=0.8),
            ),
        ),
        paper_bgcolor="#12132a",
        plot_bgcolor="#12132a",
        font=dict(color="#ECF0F1", family="monospace"),
        legend=dict(
            x=0.01,
            y=0.99,
            bgcolor="rgba(13,14,32,0.8)",
            bordercolor="#2C3E50",
            borderwidth=1,
            font=dict(color="#ECF0F1", size=11),
        ),
        margin=dict(l=0, r=0, t=90, b=0),
        height=880,
        hoverlabel=dict(
            bgcolor="#1a1a2e",
            bordercolor="#2C3E50",
            font=dict(color="white", size=12),
        ),
    )

    return fig


# ─── ENTRY POINT ──────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Visualizador 3D Jacket Offshore")
    parser.add_argument(
        "--serve", action="store_true",
        help="Después de generar el HTML, abre un servidor HTTP local en el puerto 8050"
    )
    parser.add_argument(
        "--port", type=int, default=8050,
        help="Puerto para --serve (default: 8050)"
    )
    args = parser.parse_args()

    # Verificar Excel
    if not EXCEL_PATH.exists():
        print(f"ERROR: No se encontró el Excel en:\n  {EXCEL_PATH}")
        sys.exit(1)

    print(f"Cargando datos desde:\n  {EXCEL_PATH}")
    data = load_excel(EXCEL_PATH)

    n = data["nodos"]
    e = data["elements"]
    print(f"  Nodos     : {len(n)}")
    print(f"  Beam      : {len(e['Beam'])}")
    print(f"  Brace     : {len(e['Brace'])}")
    print(f"  Column    : {len(e['Column'])}")
    print(f"  Empotrados: {len(data['restrained_points'])} nodos")
    print()

    print("Construyendo figura 3D...")
    fig = build_figure(data)

    print(f"Exportando HTML → {OUT_HTML}")
    fig.write_html(
        OUT_HTML,
        include_plotlyjs="cdn",
        full_html=True,
        config={
            "scrollZoom": True,
            "displayModeBar": True,
            "modeBarButtonsToRemove": ["toImage"],
            "displaylogo": False,
        },
    )
    print(f"✓ HTML generado: {OUT_HTML}")
    print()
    print(f"  Abrir en el navegador:")
    print(f"    xdg-open {OUT_HTML}")

    if args.serve:
        import http.server
        import socketserver
        import threading
        import webbrowser

        os_chdir = Path(__file__).parent
        handler = http.server.SimpleHTTPRequestHandler

        class QuietHandler(handler):
            def log_message(self, fmt, *a):
                pass  # silencia logs de cada request

        print()
        print(f"Servidor HTTP local → http://localhost:{args.port}/jacket_3d.html")
        print("  Ctrl+C para detener")

        # Cambiar al directorio de salida para servir el HTML
        import os
        os.chdir(os_chdir)

        with socketserver.TCPServer(("", args.port), QuietHandler) as httpd:
            url = f"http://localhost:{args.port}/jacket_3d.html"
            threading.Timer(0.5, lambda: webbrowser.open(url)).start()
            try:
                httpd.serve_forever()
            except KeyboardInterrupt:
                print("\nServidor detenido.")


if __name__ == "__main__":
    main()

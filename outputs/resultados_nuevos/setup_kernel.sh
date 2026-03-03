#!/bin/bash
# Script para crear kernel de Jupyter para análisis de resultados 2026
# Fecha: 2 de marzo de 2026
# Uso: bash setup_kernel.sh

set -e  # Salir si hay algún error

echo "========================================================================"
echo "Configurando kernel de Jupyter para análisis de resultados 2026"
echo "========================================================================"
echo ""

# Nombre del entorno
ENV_NAME="analisis_resultados_2026"
PYTHON_VERSION="3.9"

# 1. Crear entorno conda (si no existe)
echo "1️⃣  Creando entorno conda: $ENV_NAME"
if conda env list | grep -q "^$ENV_NAME "; then
    echo "   ⚠️  El entorno $ENV_NAME ya existe. Eliminándolo..."
    conda env remove -n $ENV_NAME -y
fi

conda create -n $ENV_NAME python=$PYTHON_VERSION -y
echo "   ✓ Entorno creado exitosamente"
echo ""

# 2. Activar entorno e instalar dependencias
echo "2️⃣  Instalando dependencias..."
source $(conda info --base)/etc/profile.d/conda.sh
conda activate $ENV_NAME

# Core dependencies
echo "   📦 Instalando librerías core..."
conda install -y \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scipy \
    jupyter \
    notebook \
    ipykernel

# PyPI dependencies
echo "   📦 Instalando librerías adicionales..."
pip install openpyxl tqdm

echo "   ✓ Dependencias instaladas exitosamente"
echo ""

# 3. Registrar kernel en Jupyter
echo "3️⃣  Registrando kernel en Jupyter..."
python -m ipykernel install --user --name=$ENV_NAME --display-name "Python (Análisis 2026)"
echo "   ✓ Kernel registrado exitosamente"
echo ""

# 4. Verificar instalación
echo "4️⃣  Verificando instalación..."
echo ""
echo "   Librerías instaladas:"
python << 'PYEOF'
import sys
packages = {
    'pandas': None,
    'numpy': None,
    'matplotlib': None,
    'seaborn': None,
    'scipy': None,
    'openpyxl': None,
    'tqdm': None,
    'jupyter': None,
    'ipykernel': None
}

for pkg in packages:
    try:
        module = __import__(pkg)
        version = getattr(module, '__version__', 'unknown')
        print(f"     ✓ {pkg:15s} {version}")
    except ImportError:
        print(f"     ✗ {pkg:15s} NO INSTALADO")
PYEOF

echo ""
echo "========================================================================"
echo "✅ Configuración completada exitosamente"
echo "========================================================================"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "1. Iniciar Jupyter Notebook:"
echo "   $ cd ~/github/Proyecto-doctoral/outputs/resultados_nuevos"
echo "   $ jupyter notebook"
echo ""
echo "2. Al abrir los notebooks, seleccionar kernel:"
echo "   Kernel > Change kernel > Python (Análisis 2026)"
echo ""
echo "3. Si prefieres ejecutar desde terminal:"
echo "   $ conda activate $ENV_NAME"
echo "   $ jupyter nbconvert --to notebook --execute 01_extraer_detecciones_nodos.ipynb"
echo ""
echo "========================================================================" 

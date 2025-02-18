FROM python:3.13-slim

# Build-time arguments with default values
ARG INSTALL_EIGEN="ON"
ARG INSTALL_GSL="ON"
ARG MAKE_NPROCS="4"
ARG NS3_CONFIGURE_OPTIONS="--enable-examples --enable-tests --enable-python-bindings"

# Install required system dependencies in one layer.
# Optional dependencies (Eigen and GSL) are conditionally installed.
RUN apt update && \
    apt install -y \
      g++ \
      python3 \
      cmake \
      ninja-build \
      git \
      qtbase5-dev \
      qtchooser \
      qt5-qmake \
      qtbase5-dev-tools \
      sqlite3 \
      libsqlite3-dev \
      wget \
      libxml2-dev && \
    if [ "$INSTALL_EIGEN" = "ON" ]; then \
      apt install -y libeigen3-dev; \
    fi && \
    if [ "$INSTALL_GSL" = "ON" ]; then \
      apt install -y libgsl0-dev; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# Copy ns-3 source from the repository (assumed to be in extern/ns3)
COPY extern/ns3 /usr/local/src/ns3
WORKDIR /usr/local/src/ns3
ENV NS3_BINDINGS_INSTALL_DIR=/usr/local/lib/python3.13/site-packages

# Install cppyy using the specified number of parallel jobs.
RUN MAKE_NPROCS=${MAKE_NPROCS} pip install --verbose cppyy --no-binary=cppyy-cling

# Configure ns-3 with custom options.
RUN ./ns3 configure ${NS3_CONFIGURE_OPTIONS}

# Extend the build by copying custom simulation scenarios.
# Place your custom scenario source files in the repository folder "custom-scenarios".
# They will be copied to ns-3's "scratch/custom-scenarios" directory.
# COPY custom-scenarios/ ./scratch/custom-scenarios/

# Build ns-3 (this will also compile code in the scratch directory) in parallel.
RUN ./ns3 build -j${MAKE_NPROCS}

# Install ns-3 (libraries, Python bindings, etc.)
RUN ./ns3 install

# Set default command (can be overridden by docker-compose or runtime)
CMD ["python3"]

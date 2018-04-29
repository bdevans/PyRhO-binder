#FROM jupyter/scipy-notebook:latest
#96f2f777be6e
# Binder requires a specific version
#FROM jupyter/minimal-notebook
FROM jupyter/base-notebook

LABEL maintainer="Project PyRhO <projectpyrho@gmail.com>"

USER root
ARG DEBIAN_FRONTEND=noninteractive

# libav-tools for matplotlib anim
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    #libav-tools \
                    git \
                    #mercurial \
                    #mercurial-common \
                    #gcc \
                    #g++ \
                    #gfortran \
                    autotools-dev \
                    autoconf \
                    automake \
                    build-essential \
                    libtool \
                    bison \
                    flex \
                    libncurses5-dev \
                    #libncursesw5-dev \
                    libtinfo-dev \
                    libreadline-dev \
                    #liblapack-dev \
                    #libblas-dev \
                    #libatlas-dev \
                    #libatlas-base-dev \
                    #libxext-dev \
                    #libxft-dev \
                    #xfonts-100dpi \
                    #libfreetype6-dev \
                    #openmpi-doc \
                    #openmpi-common \
                    #libmpich-dev && \
                    #openmpi-bin \
                    libopenmpi-dev && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
# Official Debian and Ubuntu images automatically run apt-get clean

### Change locale to en_GB
#RUN echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
#    locale-gen
#ENV LC_ALL en_GB.UTF-8
#ENV LANG en_GB.UTF-8
#ENV LANGUAGE en_GB.UTF-8

USER ${NB_USER}

RUN conda config --add channels brian-team

# Install Python 3 packages
RUN conda install --quiet --yes \
    'pip=9.0*' \
    #'ipython=4.1*' \
    #'ipywidgets=7.1*' \
    #'numexpr=2.6*' \
    #'scipy=1.0*' \
    #'sympy=1.1*' \
    #'cython=0.27*' \
    #'bokeh=0.12*' \
    'matplotlib=2.2*' \
    'seaborn=0.8*' \
    'pandas=0.22*' \
    'h5py=2.7*' \
    'pytest=3.4*' \
    #'nose=1.3*' \
    'brian2=2.1*' \
    'brian2tools=0.2*' \
    && conda clean -tipsy

#USER root
RUN pip install --upgrade pip
#RUN conda list

### NEURON installation
USER ${NB_USER}
ENV ARCH x86_64
#ARG ARCH=`uname -m`
RUN echo $ARCH
#ARG NCORES=$(nproc)
ENV NCORES 4
RUN echo $NCORES
RUN printenv
#ENV LD_LIBRARY_PATH $CONDA_DIR/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu:/usr/lib:$CONDA_DIR/lib
#RUN ls /usr/lib
#RUN ls /usr/share
#RUN dpkg -L libreadline-dev
#RUN find /usr -name "libtinfo.so*"
RUN echo $PATH
#ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/conda/bin
ENV NDIR $HOME/neuron
#USER root
#ENV NDIR /opt/neuron
#ENV NRNPY /home/main/anaconda2/envs/python3/bin/python3
#ENV NRNPY `which python`

RUN mkdir $NDIR
WORKDIR $NDIR
ENV LD_LIBRARY_PATH $NDIR/nrn/$ARCH/lib:$LD_LIBRARY_PATH

ENV VNRN 7.5
#ENV VIV 19
RUN wget -q http://www.neuron.yale.edu/ftp/neuron/versions/v$VNRN/nrn-$VNRN.tar.gz
#RUN wget -q http://www.neuron.yale.edu/ftp/neuron/versions/v$VNRN/iv-$VIV.tar.gz
#RUN tar xzf iv-$VIV.tar.gz; rm iv-$VIV.tar.gz; mv iv-$VIV iv
RUN tar xzf nrn-$VNRN.tar.gz; rm nrn-$VNRN.tar.gz; mv nrn-$VNRN nrn
# https://neuron.yale.edu/ftp/neuron/versions/v7.5/nrn-7.5.tar.gz

#RUN git clone https://github.com/nrnhines/nrn.git
RUN conda list
RUN conda remove --force ncurses
#readline
#RUN cd $NDIR/iv; ./build.sh; ./configure --prefix=`pwd` --with-x --x-includes=/usr/include/ --x-libraries=/usr/lib/ && make && make install
#RUN cd $NDIR/nrn; sh src/nrnmpi/mkdynam.sh; ./build.sh;
RUN cd $NDIR/nrn; ./build.sh;
#RUN cd $NDIR/nrn; 2to3 -w src/oc/mk_hocusr_h.py; sed -i '1i from __future__ import print_function' src/oc/mk_hocusr_h.py
#RUN cd $NDIR/nrn; sed -i.bak -e "s/print sys.api_version,/from __future__ import print_function; print(sys.api_version)/" configure
#RUN cd $NDIR/nrn; ./configure --prefix=`pwd` --with-nrnpython=$NRNPY --with-paranrn=dynamic --with-iv=$NDIR/iv \
#--with-x --x-includes=/usr/include/ --x-libraries=/usr/lib/ --with-mpi && make && make install
RUN cd $NDIR/nrn; ./configure --prefix=`pwd` --without-x --without-iv --with-nrnpython --with-paranrn --disable-rx3d
#  --libdir=/usr/lib/x86_64-linux-gnu
# --with-readline=/usr/lib
# --libdir=/usr/lib
# && make -j$NCORES && make install
#RUN ls $NDIR/nrn
#RUN cat $NDIR/nrn/config.log
RUN cd $NDIR/nrn; make -j$NCORES && make install
# openmpi or mpich
#--with-mpi
#--with-paranrn=dynamic
#--with-nrnpython-only
USER root
#RUN echo 'export PATH=$PATH:$NDIR/iv/$ARCH/bin:$NDIR/nrn/$ARCH/bin' >> /etc/bash.bashrc
RUN echo 'export PATH=$PATH:$NDIR/nrn/$ARCH/bin' >> /etc/bash.bashrc
#RUN echo 'PYTHONPATH=$PYTHONPATH:$NDIR/nrn/lib/python'
RUN echo 'export NRN_NMODL_PATH=$NDIR' >> /etc/bash.bashrc
RUN cd $NDIR/nrn/src/nrnpython; python setup.py install
RUN chmod o+w $NDIR

USER ${NB_USER}

#ENV CPB3 /home/main/anaconda2/envs/python3/bin
### Install PyRhO
#ENV VPYRHO 0.9.4
# For upgrading: -U --ignore-installed --no-deps
## Install for Python 2
#RUN pip install pyrho[full]==$VPYRHO
#RUN ln -s /home/main/anaconda2/bin/pip /home/main/anaconda2/bin/pip2
#RUN ln -s /home/main/anaconda2/envs/python3/bin/pip /home/main/anaconda2/envs/python3/bin/pip3
RUN pip install git+https://github.com/ProjectPyRhO/PyRhO.git#egg=PyRhO[full]
## Install for Python 3
#RUN $CPB3/pip install git+https://github.com/ProjectPyRhO/PyRhO.git#egg=PyRhO[full]
# Alternative to installing for Python 3
#RUN source activate python3
#RUN pip install --ignore-installed --no-deps pyrho[full]
#RUN source deactivate

# matplotlib config (used by benchmark)
#USER root
#RUN apt-get install -y libgl1-mesa-glx
#USER ${NB_USER}
#RUN python -c "import matplotlib as mpl; mpl.use('Agg');"
RUN mkdir -p /home/${NB_USER}/.config/matplotlib
RUN echo "backend : Agg" > /home/${NB_USER}/.config/matplotlib/matplotlibrc
#RUN source /etc/bash.bashrc
ENV NRN_NMODL_PATH $NDIR
WORKDIR /home/${NB_USER}
RUN python -c "from pyrho import *; setupNEURON()"

# notebooks created by binder
COPY index.ipynb /home/${NB_USER}/index.ipynb
#RUN jupyter nbconvert --inplace --to notebook *.ipynb
#--output 'index.ipynb'
#USER root
### Copy demonstration notebook and config files to home directory
#RUN find /home/${NB_USER} -name '*.ipynb' -exec jupyter nbconvert --to notebook {} --output {} \; && \
#    chown -R ${NB_USER}:${NB_GID} /home/${NB_USER}

#COPY jupyter_notebook_config.py $HOME/.jupyter/
#RUN chown -R main:main $HOME/notebooks
#RUN chown -R ${NB_USER}:${NB_GID} $NDIR

# Install our custom.js
COPY resources/custom.js /home/${NB_USER}/.jupyter/custom/

# TODO: Check for /srv/ and /tmp/
USER root
COPY resources/templates/ /srv/templates/
RUN chmod a+rX /srv/templates

# Append tmpnb specific options to the base config
COPY resources/jupyter_notebook_config.partial.py /tmp/
RUN cat /tmp/jupyter_notebook_config.partial.py >> /home/${NB_USER}/.jupyter/jupyter_notebook_config.py && \
    rm /tmp/jupyter_notebook_config.partial.py

RUN chown -R ${NB_USER}:${NB_GID} ${HOME}

USER ${NB_USER}
RUN find . -name '*.ipynb' -exec jupyter trust {} \;

# Fix matplotlib font cache
#RUN rm -rf /home/${NB_USER}/.matplolib
#RUN rm -rf /home/${NB_USER}/.cache/matplolib
#RUN rm -rf /home/${NB_USER}/.cache/fontconfig
#RUN python -c "import matplotlib.pyplot as plt"

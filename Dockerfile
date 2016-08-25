FROM andrewosh/binder-base
# https://github.com/binder-project/binder-build-core/blob/master/images/base/Dockerfile

MAINTAINER Project PyRhO <projectpyrho@gmail.com>

USER root

# libav-tools for matplotlib anim
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    libav-tools \
                    git \
                    gcc \
                    g++ \
                    gfortran \
                    libatlas-dev \
                    libatlas-base-dev \
                    libfreetype6-dev \
                    autotools-dev \
                    autoconf \
                    automake \
                    libtool \
                    bison \
                    flex \
                    xfonts-100dpi \
                    libncurses5-dev \
                    libxext-dev \
                    libreadline-dev \
                    libopenmpi-dev \
                    openmpi-bin \
                    openmpi-doc \
                    openmpi-common \
                    liblapack-dev \
                    libblas-dev \
                    libxft-dev \
                    mercurial \
                    mercurial-common && \
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

USER main

RUN conda config --add channels brian-team

# Install Python 2 packages
RUN conda install --quiet --yes \
    'pip=8.1*' \
    #'ipython=4.1*' \
    #'ipywidgets=4.1*' \
    #'numexpr=2.5*' \
    #'scipy=0.17*' \
    #'sympy=0.7*' \
    #'cython=0.24*' \
    #'bokeh=0.11*' \
    'matplotlib=1.5*' \
    'seaborn=0.7*' \
    'pandas=0.18*' \
    'h5py=2.6*' \
    'nose=1.3*' \
    'brian2' \
    'brian2tools' \
    #'pyzmq' \
    && conda clean -tipsy

# Install Python 3 packages
RUN conda install --quiet --yes -n python3 \
    'pip=8.1*' \
    #'ipywidgets=4.1*' \
    #'numexpr=2.5*' \
    #'scipy=0.17*' \
    #'sympy=0.7*' \
    #'cython=0.24*' \
    #'bokeh=0.11*' \
    'matplotlib=1.5*' \
    'seaborn=0.7*' \
    'pandas=0.18*' \
    'h5py=2.6*' \
    'nose=1.3*' \
    'brian2' \
    'brian2tools' \
    && conda clean -tipsy

USER root

### NEURON installation

ENV NDIR $HOME/neuron
ENV NRNPY /home/main/anaconda2/envs/python3/bin/python3
ENV ARCH x86_64

RUN mkdir $NDIR
WORKDIR $NDIR

ENV VNRN 7.4
ENV VIV 19
RUN wget -q http://www.neuron.yale.edu/ftp/neuron/versions/v$VNRN/nrn-$VNRN.tar.gz
RUN wget -q http://www.neuron.yale.edu/ftp/neuron/versions/v$VNRN/iv-$VIV.tar.gz
RUN tar xzf iv-$VIV.tar.gz; rm iv-$VIV.tar.gz; mv iv-$VIV iv
RUN tar xzf nrn-$VNRN.tar.gz; rm nrn-$VNRN.tar.gz; mv nrn-$VNRN nrn
#RUN cd $NDIR; hg clone http://www.neuron.yale.edu/hg/neuron/nrn
#RUN cd $NDIR; hg clone http://www.neuron.yale.edu/hg/neuron/iv

RUN cd $NDIR/iv; ./build.sh; ./configure --prefix=`pwd` --with-x --x-includes=/usr/include/ --x-libraries=/usr/lib/ && make && make install
#RUN cd $NDIR/nrn; sh src/nrnmpi/mkdynam.sh; ./build.sh;
RUN cd $NDIR/nrn; ./build.sh;
RUN cd $NDIR/nrn; 2to3 -w src/oc/mk_hocusr_h.py; sed -i '1i from __future__ import print_function' src/oc/mk_hocusr_h.py
RUN cd $NDIR/nrn; sed -i.bak -e "s/print sys.api_version,/from __future__ import print_function; print(sys.api_version)/" configure
RUN cd $NDIR/nrn; ./configure --prefix=`pwd` --with-iv=$NDIR/iv --with-nrnpython=$NRNPY --with-paranrn=dynamic \
--with-x --x-includes=/usr/include/ --x-libraries=/usr/lib/ --with-mpi && make && make install
RUN echo 'export PATH=$PATH:$NDIR/iv/$ARCH/bin:$NDIR/nrn/$ARCH/bin' >> /etc/bash.bashrc
#RUN echo 'PYTHONPATH=$PYTHONPATH:$NDIR/nrn/lib/python'
RUN echo 'export NRN_NMODL_PATH=$NDIR' >> /etc/bash.bashrc
RUN cd $NDIR/nrn/src/nrnpython; $NRNPY setup.py install
RUN chmod o+w $NDIR

USER main

ENV CPB3 /home/main/anaconda2/envs/python3/bin
### Install PyRhO
ENV VPYRHO 0.9.4
# For upgrading: -U --ignore-installed --no-deps
## Install for Python 2
#RUN pip install pyrho[full]==$VPYRHO
#RUN ln -s /home/main/anaconda2/bin/pip /home/main/anaconda2/bin/pip2
#RUN ln -s /home/main/anaconda2/envs/python3/bin/pip /home/main/anaconda2/envs/python3/bin/pip3
RUN pip install git+https://github.com/ProjectPyRhO/PyRhO.git#egg=PyRhO[full]
## Install for Python 3
RUN $CPB3/pip install git+https://github.com/ProjectPyRhO/PyRhO.git#egg=PyRhO[full]
# Alternative to installing for Python 3
#RUN source activate python3
#RUN pip install --ignore-installed --no-deps pyrho[full]
#RUN source deactivate

#RUN source /etc/bash.bashrc
ENV NRN_NMODL_PATH $NDIR
RUN python -c "from pyrho import *; setupNEURON()"

USER root
### Copy demonstration notebook and config files to home directory
RUN find /home/main/work -name '*.ipynb' -exec jupyter nbconvert --to notebook {} --output {} \; && \
    chown -R main:main /home/main
#COPY jupyter_notebook_config.py $HOME/.jupyter/
#RUN chown -R main:main $HOME/notebooks
RUN chown -R main:main $NDIR

# Install our custom.js
COPY resources/custom.js /home/main/.jupyter/custom/

# TODO: Check for /srv/ and /tmp/
#USER root
COPY resources/templates/ /srv/templates/
RUN chmod a+rX /srv/templates

# Append tmpnb specific options to the base config
COPY resources/jupyter_notebook_config.partial.py /tmp/
RUN cat /tmp/jupyter_notebook_config.partial.py >> /home/main/.jupyter/jupyter_notebook_config.py && \
    rm /tmp/jupyter_notebook_config.partial.py

USER main
RUN find . -name '*.ipynb' -exec jupyter trust {} \;

# Fix matplotlib font cache
RUN rm -rf /home/main/.matplolib
RUN rm -rf /home/main/.cache/matplolib
RUN rm -rf /home/main/.cache/fontconfig
RUN python -c "import matplotlib.pyplot as plt"

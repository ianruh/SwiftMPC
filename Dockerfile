FROM swift:bionic

# install miniconda
RUN apt update && apt install -y make liblapacke-dev

WORKDIR /Minimization

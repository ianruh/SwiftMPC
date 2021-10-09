FROM swift:5.5.0-focal

# install miniconda
RUN apt update && apt install -y make liblapacke-dev

WORKDIR /SwiftMPC

COPY . /SwiftMPC

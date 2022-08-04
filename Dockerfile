FROM debian:10.4-slim AS builder

RUN echo deb http://deb.debian.org/debian/ buster main >/etc/apt/sources.list &&\
 echo deb-src http://deb.debian.org/debian/ buster main >>/etc/apt/sources.list &&\
 echo deb http://security.debian.org/debian-security buster/updates main >>/etc/apt/sources.list &&\
 echo deb-src http://security.debian.org/debian-security buster/updates main >>/etc/apt/sources.list &&\
 echo deb http://deb.debian.org/debian/ buster-updates main >>/etc/apt/sources.list &&\
 echo deb-src http://deb.debian.org/debian/ buster-updates main >>/etc/apt/sources.list

RUN apt-get -y update &&\
    apt-get -y install make wget git gcc g++ libgmp-dev libmpfr-dev libmpc-dev flex bison gettext texinfo ncurses-dev autoconf rsync

RUN git clone https://github.com/bebbo/amiga-gcc &&\
    cd amiga-gcc &&\
    make update -j &&\
    make all all-sdk -j8



FROM debian:10.4-slim

COPY --from=builder /opt/amiga /opt/amiga

RUN echo deb http://deb.debian.org/debian/ buster main >/etc/apt/sources.list &&\
    apt-get -y update &&\
    apt-get -y install make git libmpc3 libmpfr6 libgmp10 \
        mc curl lhasa nano

ENV PATH="/opt/amiga/bin:$PATH"

RUN chmod o+r -R /opt/amiga &&\
    useradd -m -s /bin/bash test &&\
    echo 'export PATH=$PATH:/opt/amiga/bin' >> /home/test/.bashrc


WORKDIR tmp

# Install FlexCat
RUN curl -fsSL "https://github.com/adtools/flexcat/releases/download/2.18/FlexCat-2.18.lha" -o /tmp/FlexCat.lha && \
    lha -xfq2 FlexCat.lha && \
    cp ./FlexCat/Linux-i386/flexcat /usr/bin/ && \
    rm -rf /tmp/*;

RUN curl -fsSL "https://github.com/amiga-mui/muidev/releases/download/MUI-5.0-20210831/MUI-5.0-20210831-os3.lha" -o /tmp/MUI-5.0.lha && \
    lha -xfq2 MUI-5.0.lha;

RUN git clone https://github.com/walkero-gr/iGame.git -b sqlite;



# TEST MUI Examples:
# cd /tmp/SDK/MUI/C/Examples
# m68k-amigaos-gcc -o Aboutbox Aboutbox.c -noixemul -I /tmp/SDK/MUI/C/include/ -lmui -L /tmp/SDK/MUI/C/lib/
# m68k-amigaos-gcc -o Class1 Class1.c -noixemul -I /tmp/SDK/MUI/C/include/ -lmui -L /tmp/SDK/MUI/C/lib/
# 
# TEST iGame
# cd /tmp/iGame
# make
# 

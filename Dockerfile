################################################
#  NLP Tools for Polish from G4.19 Group
#  Wroclaw University of Science and Technology
#
#  Contact: Tomasz.Walkowiak@pwr.edu.pl
#  
#  WCRFT2 service   
###############################################

FROM ubuntu:16.04

RUN apt-get update  && \
   apt-get install -y apt-utils && \
   apt-get install -y iputils-ping && \
   apt-get install -y git  &&  \
   apt-get install -y subversion  &&  \
   apt-get install -y wget nano mc zip unzip && \  
   apt-get install -y vim ranger atool htop curl && \
   apt-get install -y locales locales-all   && \
   apt-get install -y python-dev && \
   apt-get install -y python-pip && \
   apt-get install -y cmake && \
   apt-get install -y g++  && \
   apt-get install -y netcat && \
   apt-get install -y swig 
        
RUN pip2 install --upgrade pip

##################################
## UTF-8
##################################
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8



##################################
# Install WCRFT2 + dependencies
##################################
RUN mkdir /home/install
WORKDIR /home/install  
  
RUN apt-get install -y libboost-all-dev libicu-dev libxml++2.6-dev bison flex libloki-dev

##CORPUS2
RUN git clone http://nlp.pwr.edu.pl/corpus2.git && \
        cd corpus2 && \
        mkdir bin &&\
        cd bin && \
        cmake -D CORPUS2_BUILD_POLIQARP:BOOL=True .. && \
        make -j4 && \
        make -j4 && \
        make install && \
        ldconfig
##WCCL
RUN apt-get update && apt-get install -y libantlr-dev && \
        git clone -b mwe_fix http://nlp.pwr.edu.pl/wccl.git && \
        cd wccl && \
        mkdir bin && \
        cd bin && \
        cmake .. && \
        make -j4 && \
        #Error after 1st “make”? Why after running “make” again everything goes OK?
        make -j4 && \
        make install && \
        ldconfig

##CORPUS2MWE (??)
RUN cd corpus2/corpus2mwe && \
      	mkdir build && \
      	cd build && \
      	cmake .. && \
      	make -j4 && \
      	make install && \
      	ldconfig

##TOKI
RUN git clone http://nlp.pwr.edu.pl/toki.git  && \
        cd toki && \
        mkdir bin && \
        cd bin && \
        cmake .. && \
        make -j4 && \
        make install && \
        ldconfig
##morfeusz-sgjp
RUN mkdir morfeusz-sgjp  && \
        cd morfeusz-sgjp && \
        wget http://sgjp.pl/morfeusz/download/morfeusz-SGJP-linux64-20130413.tar.bz2  && \
        tar -jxvf morfeusz-SGJP-linux64-20130413.tar.bz2 && \
        mv libmorfeusz* /usr/local/lib/ && \
        mv morfeusz /usr/local/bin/ && \
        mv morfeusz.h /usr/local/include/ && \
        ldconfig && \
        cd .. && \
        rm -rf morfeusz-sgjp

## Morfeusz2
RUN mkdir morfeusz  && cd morfeusz && \
    wget -O morfeusz2-2.0.0-Linux-amd64.deb https://nextcloud.clarin-pl.eu/index.php/s/VVIvx4w20azcWbp/download && \
    dpkg -i --instdir=/home/install/morfeusz morfeusz2-2.0.0-Linux-amd64.deb && \
    ln /home/install/morfeusz/usr/include/morfeusz2.h /home/install/morfeusz/usr/include/morfeusz.h && \
    dpkg -i morfeusz2-2.0.0-Linux-amd64.deb && \
    ln /usr/include/morfeusz2.h /usr/include/morfeusz.h && \
    rm -rf ../morfeusz        
        
##MACA     
RUN apt-get install -y build-essential subversion libedit-dev libreadline-dev libsfst1-1.4-dev  && \
        git clone http://nlp.pwr.edu.pl/maca.git && \
        cd maca && \
        mkdir bin && \
        cd bin && \
        cmake .. && \
        make -j4 && \
        make install && \
        ldconfig


##CRF++      
RUN wget -O download 'https://drive.google.com/uc?authuser=0&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ&export=download' && \
        tar -xvzf download && \
        rm download && \
        cd CRF++-0.58/ && \
        ./configure && \
        make && \
        make install && \
        ldconfig 


##WCRFT2    
RUN  git clone http://nlp.pwr.edu.pl/wcrft2.git && \
     cd wcrft2 && \
     mkdir bin && \
     cd bin && \
     cmake .. && \
        make -j4 && \
        make install && \
        ldconfig

##JAVA
RUN apt-get install -y openjdk-8-jdk

##LINER2
#RUN git clone https://github.com/CLARIN-PL/Liner2.git && \
#        cd Liner2 && export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" && ./gradlew jar

RUN git clone https://github.com/CLARIN-PL/Liner2.git


##FEXTOR-BIS
RUN svn checkout http://svn.clarin-pl.eu/svn/nlpservices/nlpworkers/fextor


##PLWN-API: tymczasowo niepoprawny adres
##RUN git clone http://nlp.pwr.edu.pl/plwn_api.git


RUN pip2 install wheel
        

##WOSEDON
RUN echo 'deb http://downloads.skewed.de/apt/xenial xenial universe' >> /etc/apt/sources.list && \
        echo 'deb-src http://downloads.skewed.de/apt/xenial xenial universe' >> /etc/apt/sources.list && \
        apt-get update && apt-get install -y --allow-unauthenticated python-graph-tool

RUN git clone http://nlp.pwr.edu.pl/wosedon_pub.git
RUN cd wosedon_pub/wosedon_current/tools/stdmods/corpus_ccl && python setup.py install && \
        cd ../tools && python setup.py install && \
        cd ../../PLWNGraphBuilder && python setup.py install && \
        cd ../../../wosedon_current && python setup.py install

##PARSER
RUN wget http://maltparser.org/dist/maltparser-1.9.2.zip && \
        unzip maltparser-1.9.2.zip

        
##################################
# Install WCRFT2 service + dependencies
##################################

## AMQP-CPP
RUN wget https://github.com/CopernicaMarketingSoftware/AMQP-CPP/archive/v2.8.0.tar.gz && \
    tar -xvf v2.8.0.tar.gz && \
    cd AMQP-CPP-2.8.0 && \
    make -j4 && make install && ldconfig
    

## cpp_nlp
RUN svn co http://svn.clarin-pl.eu/svn/nlpservices/src/cpp/nlp && \
    cd nlp && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j4 && \
    make install  && \
    ldconfig
    
## Wcrft2_service
RUN svn co http://svn.clarin-pl.eu/svn/nlpservices/src/cpp/wcrft2 wcrft2_service && \
    cd wcrft2_service && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j 

##CORPUS2
RUN cd corpus2 && \
        rm -rf bin && \
        mkdir bin &&\
        cd bin && \
        cmake -D CORPUS2_BUILD_POLIQARP:BOOL=True .. && \
        make -j4 && \
        make -j4 && \
        make install && \
        ldconfig

RUN mkdir /home/worker    
RUN cp /home/install/wcrft2_service/bin/* /home/worker/. 
    
COPY wait-for.sh /home/worker/wait-for.sh
RUN ["chmod", "+x", "/home/worker/wait-for.sh"]
COPY config.ini /home/worker/config.ini
COPY init.sh /init.sh


RUN ["chmod", "+x", "/init.sh"]
ENTRYPOINT ["/init.sh"]
    

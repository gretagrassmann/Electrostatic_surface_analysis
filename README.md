# Analisi di superfici elettrostatiche a partire da file pdb
Automatizzazione (speriamo) della procedura descritta <a href="https://circe.iit.uniroma1.it:9201/detail-wiki/calcolare-la-superficie-elettrostatica-di-proteine" target="_blank">qua</a>. Lo scopo e' sempre calcolare la superificie elettrostatica a partire dal file .pdb di una proteina: l'output finale e' un file .csv della superificie, in cui la cui ultima colonna riporta i valori della carica.

### Table of contents:
  * [Strumenti utilizzati](#strumenti-utilizzati)
  * [Prerequisiti](#prerequisiti)
    + [Pdb2pqr](#pdb2pqr)
    + [APBS](#apbs)
  * [Esecuzione](#esecuzione)
  * [Calcolo della superificie elettrostatica](#calcolo-della-superificie-elettrostatica)
    + [Superficie molecolare](#superficie-molecolare)
    + [Pdb2pqr](#pdb2pqr)
    + [APBS](#apbs)
    + [Dal file dx alla superificie di potenziale](#dal-file-dx-alla-superificie-di-potenziale)

## Strumenti utilizzati
1. Sitema operativo Linux basato su debian (io ho scaricato linux mint 20.2 Cinnamon).
2. Il software dms.
3. La libreria pdb2pqr di Python (io uso Python 3.9).
4. Un ambiente di lavoro R (io uso Rstudio).
5. Il software APBS (abbiamo scaricato la versione 3.0).
6. Il pacchetto rgrids.

## Prerequisiti
Di seguito riporto solo i passaggi non gia' descritti nella <a href="https://circe.iit.uniroma1.it:9201/detail-wiki/calcolare-la-superficie-elettrostatica-di-proteine" target="_blank">guida originale</a>.
<div class="note"><strong>NOTA</strong>: Sto ancora imparando a usare Linux, quindi probabilmente ci sono modi molto migliori, ma giusto per tenere nota riporto tutto. </div>

### Pdb2pqr
Aprire la cartella di lavoro che conterra' tutti i file. Conviene strutturarla come mostrato nell'esempio di seguito.
```
cartella_di_lavoro
  ├── auto.sh
  ├── cycle.sh
  ├── egrid.R
  ├── pdb_files
        ├── confA
               └── pdb.pdb
        ├── confB
               └── pdb.pdb
  ├── results_confA
  └── results_confB
```
In cartella di lavoro va creato un ambiente virtuale python, su cui installare pdb2pqr:
```
python3 -m venv venv_esurf
. venv_esurf/bin/activate
pip install pdb2pqr
```


### APBS
<a href="https://apbs.readthedocs.io/en/latest/getting/index.html" target="_blank">Qua</a> suggeriscono diverse possibilita', io ho scelto di scaricare da
<a href="https://sourceforge.net/projects/apbs/" target="_blank">SourceForge</a>.
Una volta estratto lo zip (chiamiamo la cartella apbs), si sposta nella cartella .local (home->"Mostra file nascosti"). Quindi si apre il terminale in home e si digita
```
nano .bashrc
```
per aggiungere -con i dovuti cambiamenti-
```
export LD_LIBRARY_PATH=/home/leonardo/.local/apbs/lib:${LD_LIBRARY_PATH} export
PATH=/home/leonardo/.local/apbs/bin:${PATH}
```
Infine si attivano le modifiche con 
```
source ./bashrc
```

## Esecuzione
Creare la cartella di lavoro e l'ambiente virtuale. Installare pdb2pqr e apbs. Per lanciare il programma:
```
bash cycle.sh -pdb /full/path/della_cartella_con_i_pdb -venv full/path/ambiente/virtuale/venv/ -o full/path/cartella_di_lavoro/results
```

## Calcolo della superificie elettrostatica
I seguenti passaggi sono tutti eseguiti da ***auto.sh***, che a sua volta viene eseguito in un ciclo su tutte le proteine chiamato con ***cycle.sh***.

### Superficie molecolare
A partire dal file pdb si calcola la superifice molecolare con 
```
dms nome_file.pdb -n -a -o nome_file.dms
```

### Pdb2pqr
A partire dal file pdb otteniamo i file che e' necessario dare in input ad APBS, ovvero il file .in e .pqr.
```
python3 -m pdb2pqr --apbs-input=nome_file.in -ff=<forcefield> nome_file.pdb nome_file.pqr
```
<div class="note"><strong>NOTA</strong>: Come forcefield ho scelto l'opzione CHARMM per continuita' rispetto a 
<a href="https://www.mdpi.com/2218-273X/11/12/1905" target="_blank">questo</a> lavoro.   </div>

### APBS
```
apbs --output-file=nome_file.dx nome_file.in
```


### Dal file dx alla superificie di potenziale
Questo passaggio e' descritto su <a href="https://circe.iit.uniroma1.it:9201/detail-wiki/calcolare-la-superficie-elettrostatica-di-proteine" target="_blank">wiki</a>, ed e' eseguito da ***rgrids.R***.


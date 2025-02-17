library(PogromcyDanych)
library(dplyr)
install.packages("dplyr")
install.packages("stringr")
library(stringr)
install.packages("tidyr")
library(tidyr)
colnames(auta2012)

dim(auta2012)
head(auta2012[,-ncol(auta2012)])
sum(is.na(auta2012))

install.packages("PogromcyDanych")
auta2012

## 1. Z kt�rego rocznika jest najwi�cej aut i ile ich jest?

auta2012 %>%
  group_by(Rok.produkcji)%>%
  summarise(count = n())%>%
  arrange(-count)%>% 
  head(1)

## Odp: Najwi�cej aut jest z rocznika 2011 i jest ich 17418

## 2. Kt�ra marka samochodu wyst�puje najcz�ciej w�r�d aut wyprodukowanych w 2011 roku?

auta2012 %>%
  filter(Rok.produkcji == 2011)%>%
  group_by(Marka)%>%
  summarise(count = n())%>%
  arrange(-count)%>%
  head(1)

## Odp: Najcz�ciej wyst�puje mark Skoda


## 3. Ile jest aut z silnikiem diesla wyprodukowanych w latach 2005-2011?

auta2012 %>%
  filter(Rok.produkcji >= 2005 & Rok.produkcji <= 2011 & Rodzaj.paliwa == "olej napedowy (diesel)")%>%
  nrow

## Odp: Jest ich 59534



## 4. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2011 roku, kt�ra marka jest �rednio najdro�sza?
auta2012 %>%
  filter(Rok.produkcji == 2011 & Rodzaj.paliwa == "olej napedowy (diesel)")%>%
  group_by(Marka)%>%
  summarise(srednia_cena = mean(Cena))%>%
  slice_max(srednia_cena)

## Odp: Marka Volvo


## 5. Spo�r�d aut marki Skoda wyprodukowanych w 2011 roku, kt�ry model jest �rednio najta�szy?

auta2012 %>%
  filter(Rok.produkcji == 2011 & Marka == "Skoda")%>%
  group_by(Model)%>%
  summarise(srednia_cena = mean(Cena))%>%
  arrange(srednia_cena)%>%
  head(1)

## Odp:Skoda Fabia


## 6. Kt�ra skrzynia bieg�w wyst�puje najcz�ciej w�r�d 2/3-drzwiowych aut,
##    kt�rych stosunek ceny w PLN do KM wynosi ponad 600?
auta2012 %>%
  filter((Cena.w.PLN /KM) > 600 & Liczba.drzwi == "2/3") %>%
  group_by(Skrzynia.biegow)%>%
  summarise(count = n())%>%
  slice_max(count)
  
## Odp: Najcz�ciej wyst�puje skrzynia automatyczna


## 7. Spo�r�d aut marki Skoda, kt�ry model ma najmniejsz� r�nic� �rednich cen 
##    mi�dzy samochodami z silnikiem benzynowym, a diesel?

auta2012 %>% 
  filter(Marka == "Skoda" & Rodzaj.paliwa =="olej napedowy (diesel)"| Rodzaj.paliwa == "benzyna")%>%
  group_by(Model,Rodzaj.paliwa) %>%
  summarise(srednia_cena = mean(Cena)) %>%
  mutate(roznica = abs(srednia_cena-lead(srednia_cena))) %>%
  ungroup %>%
  slice_min(roznica)

## Odp: Practik

## 8. Znajd� najrzadziej i najcz�ciej wyst�puj�ce wyposa�enie/a dodatkowe 
##    samochod�w marki Lamborghini ??


auta2012 %>%
  filter(Marka =="Lamborghini")%>%
  select(Wyposazenie.dodatkowe)%>%
  mutate(Wyposazenie.dodatkowe = str_split(Wyposazenie.dodatkowe, ",")) %>% 
  unnest()%>%
  group_by(Wyposazenie.dodatkowe) %>%
  summarise(liczba = n())%>%
  arrange(liczba)%>%
  head()
  #arrange(-liczba)%>%
  #head()
 

## Odp: Najczesciej wystepuje abs, wpsomaganie keirownicy, alufelgi a najrzadziej blokada skrzyni i klatka
## 9. Por�wnaj �redni� i median� mocy KM mi�dzy grupami modeli A, S i RS 
##    samochod�w marki Audi


auta2012 %>%
  filter(Marka == "Audi")%>%
  mutate(new_col = str_extract( Model, "[A-Za-z]+"))%>%
  group_by(new_col)%>%
  select(new_col, KM, Model)%>%
  summarise(mediana = median(KM, na.rm=TRUE),
            srednia = mean(KM, na.rm=TRUE))%>%
  filter(new_col == "A" | new_col == "S"  | new_col == "RS" )%>%
  head()
  

## Odp: Dla grupy RS i A: mediana < �rednia, dla S mediana jest r�wna �rdniej 
#new_col mediana srednia
#1 A           140    160.
#2 RS          450    500.
#3 S           344    344.


## 10. Znajd� marki, kt�rych auta wyst�puj� w danych ponad 10000 razy.
##     Podaj najpopularniejszy kolor najpopularniejszego modelu dla ka�dej z tych marek.


auta2012 %>%
  select(Marka, Kolor, Model)%>%
  group_by(Marka) %>%
  mutate(liczba_aut = n())%>%
  filter(liczba_aut > 10000 & !(Marka == "") & !(Model == ""))%>%
  group_by(Marka, Model)%>%
  mutate(liczba_modeli = n())%>%
  group_by(Marka)%>%
  top_n(liczba_modeli)%>%
  ungroup %>%
  group_by(Marka, Model, Kolor)%>%
  mutate(count = n())%>%
  ungroup %>%
  group_by(Marka, Model)%>%
  top_n(count)%>%
  distinct()

## Odp:1 Ford          srebrny-metallic Focus      
      #2 Volkswagen    srebrny-metallic Passat
      #3 Opel          srebrny-metallic Astra      
      #4 BMW           srebrny-metallic 320         
      #5 Renault       srebrny-metallic Megane      
      #6 Mercedes-Benz srebrny-metallic C 220       
      #7 Audi          czarny-metallic  A4  

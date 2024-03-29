#### Carregando Pacotes ####
library('openxlsx')
library('dplyr')
library('tidyverse')
library('stringr')
library('tidyr')

#### Lendo a base de dados ####
df=read.xlsx("C:\\Users\\franc\\OneDrive\\Ãrea de Trabalho\\a.xlsx")

#### Listando as variaveis e suas respectivas tipologias ####
Dados <- function(df) {
  data.frame(
    col_index = 1:ncol(df),
    col_name = colnames(df),
    col_class = sapply(df, class),
    row.names = NULL
  )
}

Dados (df)

df1 <- Dados (df)

#### Transformando as variaveis caractere em fator ####
for (i in 1:ncol(df)){
  if(is.character(df[,i])){
    df[,i]=factor(df[,i])
  }
}

#### Transformando as variaveis numericas em factor ####
for (i in 1:ncol(df)){
  if(is.numeric(df[,i])){
    df[,i]=factor(df[,i])
  }
}

#### Levels em todas as variaveis do data frame ####
df2 = sapply(df, levels)

#### Tranformando a lista em data frame ####
df3 <- df2 %>%
  #unlist(recursive = FALSE) %>% 
  enframe() %>% 
  unnest()

#### Contando o numero de caracteres por nivel de variavel ####
df3$noChar <- nchar(df3$value)

#### Selecionando o maior numero de carateres por nivel de variavel ####
df4 = df3 %>%
  group_by(name)%>%
  summarize(Estimativa_Caracteres = max (noChar, na.rm=TRUE))%>%
  rename(col_name = name)

#### Numerando cada nivel de variavel####
df3 = df3 %>%
  group_by(name) %>%
  mutate(id_nivel=row_number())

#### Concatenando os identificadores aos niveis de variaveis ####
df3 <- df3 %>%
  mutate(value = paste(id_nivel, value, sep = " - "))

#### Agupando os niveis de variaveis em linhas ####
df3 = df3 %>%
  group_by(name) %>%
  summarise(value = paste(value, collapse = " ; "))%>%
  rename(col_name = name)

#### Unificando os data frames ####
df5 = left_join(df1, df4, by="col_name")

#### Fim ####
df_final = left_join(df5, df3, by="col_name")

#### inserindo campos ####
df_final = df_final%>%
  add_column(hub="",
             produto="",
             planilha="",
             codigo="",
             casas_decimais="",
             requerido="",
             multipla_resposta="",
             descricao="",
             regra_validacao="")

#### Ordenando campos ####
df_final = df_final %>%
  select(col_index, hub, produto, planilha, codigo, col_name, col_class, 
         Estimativa_Caracteres, casas_decimais, requerido, multipla_resposta,
         descricao, regra_validacao, value)

write.xlsx(df_final,"C:\\Users\\franc\\OneDrive\\Area de Trabalho\\dicionario.xlsx")



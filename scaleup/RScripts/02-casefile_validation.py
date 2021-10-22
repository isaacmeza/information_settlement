#!/usr/bin/env python 

import pandas as pd
import numpy as np
import random
import pylab as pl
from scipy import optimize
import time
import feather
import csv

df = feather.read_dataframe('../data/seguimiento_audiencias_val.feather')

# Arreglamos manualmente dos errorcitos
df[['erd3_litigios','era3_litigios']] = df[['erd3_litigios','era3_litigios']].apply(pd.to_numeric, errors = 'coerce')
df['id'] = df['junta'].map(str) + '_' + df['expediente'].map(str) + '_' + df['anio'].map(str)

# Crear dos funciones de validación. Para cada variable, validar 
# y luego pegarle el nombre de la variable que falló, si no cumple con el criterio
def valida_cat(var, rango):
    df[var][(~df[var].isin(rango)) & (~pd.isnull(df[var]))] = var + '_rango'
    return[df[var]]

def valida_na(var):
    df[var][pd.isnull(df[var])] = var + '_na'
    return[df[var]]

# Creamos un diccionario que contenga todos los tipos de variable, con nombre y rango
valida = {'dummies':{'rango':
                     list(range(0,2)), 
               'vars':['registro_actor',
                       'ficha_p_actora',
                       'ficha_p_dem',
                       'registro_p_actora',
                       'registro_p_dem2',
                       'calcu_p_actora',
                       'calcu_p_dem',
                       'aviso_conciliador',
                       'convenio',
                       'desistimiento',
                       'ea4_compra',
                       'ea6_trabaja',
                      'ea7_busca_trabajo']},
        'cat_3':{'rango':
           list(range(0,4)),
            'vars':['emplazamiento','tratamiento']
           },
         'cat_4':{'rango':
                  list(range(0,5)),
                 'vars':['ea3_enojo', 
                           'ea5_estudios', 
                           'ed3_estabilidad',
                           'ed4_enojo', 
                           'era3_litigios',
                           'erd3_litigios']}}

# Corremos ambas validaciones
for val in valida:
    rango_aux = valida[val]['rango']
    for var in valida[val]['vars']:
        valida_cat(var, rango_aux)

for var in ['convenio', 'desistimiento', 'emplazamiento']:
    valida_na(var)

var_list = valida['dummies']['vars'] + valida['cat_4']['vars']
var_list.append(valida['cat_3']['vars'])

# Para cada celda en el df, revisamos si tiene algún error
# En caso de tenerlo, tomamos su id de expediente y su tipo de error
# Estoy SEGURA de que hay una manera mucho más eficiente de hacer esto
# Pendiente: ¿alguna dummy de error y filtrar por esos?
error_list = []
for i in range(len(df.index)):
    for var in var_list:
        if (df[var].iloc[i] == var + '_rango') | (df[var].iloc[i] == var + '_na'):
            error_list.append(df['id'].iloc[i] + ' : ' + df[var].iloc[i])

error_list = [i.split(' : ') for i in error_list]

# Guardamos los errores en un .csv
np.savetxt('validaciones.csv', error_list, delimiter=",", fmt='%s', header = 'validaciones_seguimiento')
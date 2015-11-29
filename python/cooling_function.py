# -*- coding: utf-8 -*-
"""
Created on Sat Nov 21 23:45:39 2015

@author: carla
"""

import read_ei
import read_cr
import read_levels
import population
from population import reduce_vj_repr, coolingFunction
import matplotlib.pyplot as plt

from numpy import zeros
from IPython.core.debugger import Tracer
from numpy import log10, unique

nc = 1.e9 #corresponding to 1.e3 cm-3 as in Lipovka

# read the energy levels of H2
en_H2 = read_levels.read_levels("Read/H2Xvjlevels.cs")

# read the collisional rates for H2 with H
cr, T, ini, fin, vj_unique = read_cr.read_coeff("Read/Rates_H_H2.dat")

# read the einstein coefficients for the H2 transitions
A = read_ei.read_einstein()

# reduce the level representation from 2D indexing to 1D indexing
lin_data = reduce_vj_repr(en_H2, A, cr, T, ini, fin, vj_unique)
en_l, a_eins_l, cr_l, ini_l, fin_l, vj_unique_l, g = lin_data

cf = zeros(T.size)
for itemp in range(T.size):
    matrix = population.computeRateMatrix(en_l,
                                      a_eins_l,
                                      cr_l,
                                      ini_l,
                                      fin_l,
                                      vj_unique_l,
                                      g,
                                      T,
                                      nc,
                                      itemp)

    nvj = population.solveEquilibrium(matrix)
    cooling_function = population.coolingFunction(nvj,
                                              en_l,
                                              a_eins_l,
                                              T,
                                              ini_l,
                                              fin_l,
                                              vj_unique_l,
                                              itemp)
    cf[itemp] = cooling_function

    print cooling_function*1e13 # to have the output in erg cm-3 s-1


plt.plot(T, cf*1e13, '-')
plt.xscale('log')
plt.yscale('log')
plt.show()



## plotting the population densities

# def plot_vj_populations(v, j, nvj):
#     import pylab
#     from mpl_toolkits.mplot3d import Axes3D
#     fig = plt.figure()
#     ax = fig.add_subplot(111, projection='3d')
#     ax.plot(v, j, nvj, 'o')
#     ax.axes.xaxis.set_ticks(unique(v))
#     ax.axes.yaxis.set_ticks(unique(j)[::2])
#     ax.set_xlabel('v')
#     ax.set_ylabel('j')
#     ax.set_zlabel('n(v,j)')
#     pylab.show()
#
# plot_vj_populations(vj_unique[0], vj_unique[1], log10(nvj.flatten()))

print 'done reading!'
# -*- coding: utf-8 -*-
"""
Calculate equilibrium population of species and the cooling function using the
Lique data.
"""
from __future__ import print_function
import matplotlib.pyplot as plt
import numpy

from astropy import units as u

from frigus.cooling_function.fits import fit_glover
from frigus.population import (cooling_rate_at_steady_state,
                               population_density_at_steady_state)
from frigus.readers.dataset import DataLoader

import matplotlib
from matplotlib.ticker import ScalarFormatter

from decimal import Decimal

species_data = DataLoader().load('H2_lique')
species_data_wrathmall = DataLoader().load('H2_wrathmall')

plt.ion()
#fig, axs = plt.subplots(figsize=(8, 8))

# density of the colliding species, in m^3
nc_h_rng = [
               1.e6, 1.e7, 1.e8, 1.e9, 1.e10, 1.e11, 1.e12, 1.e13, 1.e14
           ] * u.meter ** -3
t_rad = 0.0 * u.Kelvin

t_rng = numpy.logspace(2, 3.6, 10) * u.Kelvin
# T_rng = species_data.raw_data.collision_rates_T_range

plot_markers = [(2 + i//2, 1 + i % 2, 0) for i in range(16)]

for nc_index, nc_h in enumerate(nc_h_rng):

    lambda_vs_t_kin = []
    lambda_vs_t_kin_wrathmall = []
    pop_dens_vs_t_kin = []

    for i, t_kin in enumerate(t_rng):
        print(t_kin, nc_h)

        lambda_vs_t_kin += [
            cooling_rate_at_steady_state(
                species_data,
                t_kin,
                t_rad,
                nc_h)
        ]

        pop_dens_vs_t_kin += [
            population_density_at_steady_state(species_data, t_kin, t_rad, nc_h)
        ]

        lambda_vs_t_kin_wrathmall += [
            cooling_rate_at_steady_state(
                species_data_wrathmall,
                t_kin,
                t_rad,
                nc_h)
        ]
        print(t_kin,
          pop_dens_vs_t_kin[i][0],
          pop_dens_vs_t_kin[i][2],
          pop_dens_vs_t_kin[i][4],
          pop_dens_vs_t_kin[i][6],
          pop_dens_vs_t_kin[i][8],
          pop_dens_vs_t_kin[i][10],
          pop_dens_vs_t_kin[i][12],
          pop_dens_vs_t_kin[i][14],
          pop_dens_vs_t_kin[i][16],
          pop_dens_vs_t_kin[i][1],
          pop_dens_vs_t_kin[i][3],
          pop_dens_vs_t_kin[i][5],
          pop_dens_vs_t_kin[i][7],
          pop_dens_vs_t_kin[i][9],
          pop_dens_vs_t_kin[i][11],
          pop_dens_vs_t_kin[i][13],
          pop_dens_vs_t_kin[i][15],
          pop_dens_vs_t_kin[i][17]
            )


    lambda_vs_t_kin = u.Quantity(lambda_vs_t_kin)
    lambda_vs_t_kin_wrathmall = u.Quantity(lambda_vs_t_kin_wrathmall)

    axs.loglog(
        t_rng.value, lambda_vs_t_kin.to(u.Joule / u.second).value,
        '-x', color='black', marker=plot_markers[nc_index]
    )

    axs.loglog(
        t_rng.value, lambda_vs_t_kin_wrathmall.to(u.Joule / u.second).value,
        '-.', color='green', marker=plot_markers[nc_index]
    )

axs.set_xlabel('T$_\mathrm{kin}$ [K]')
axs.set_ylabel('cooling function [J $\cdot$ s$^{-1}$]')

lambda_vs_t_kin_glover = u.Quantity(
    [fit_glover(_t_kin) for _t_kin in t_rng.value]
) * (1.0e6 * u.meter**-3)

axs.loglog(
    t_rng.value, lambda_vs_t_kin_glover.to(u.Joule / u.second).value,
    'r--', color='blue'
)


axs.set_yticks([1e-36, 2e-36, 3e-36, 4e-36, 5e-36, 6e-36, 7e-36, 8e-36, 9e-36,
                1e-35, 2e-35, 3e-35, 4e-35, 5e-35, 6e-35, 7e-35, 8e-35, 9e-35,
                1e-34, 2e-34, 3e-34, 4e-34, 5e-34, 6e-34, 7e-34, 8e-34, 9e-34,
                1e-33, 2e-33, 3e-33, 4e-33, 5e-33, 6e-33, 7e-33, 8e-33, 9e-33,
                1e-32, 2e-32, 3e-32, 4e-32, 5e-32, 6e-32, 7e-32, 8e-32, 9e-32,
                1e-31, 2e-31, 3e-31, 4e-31, 5e-31, 6e-31, 7e-31, 8e-31, 9e-31,
                1e-30, 2e-30, 3e-30, 4e-30, 5e-30, 6e-30, 7e-30, 8e-30, 9e-30,
                1e-29, 2e-29, 3e-29, 4e-29, 5e-29, 6e-29, 7e-29, 8e-29, 9e-29,
                1e-28, 2e-28, 3e-28, 4e-28, 5e-28, 6e-28, 7e-28, 8e-28, 9e-28,
                1e-27, 2e-27, 3e-27, 4e-27, 5e-27, 6e-27, 7e-27, 8e-27, 9e-27,
                1e-26, 2e-26, 3e-26])


matplotlib.pyplot.ylim(ymin = 3e-36, ymax=3e-26)

axs.get_yaxis().set_minor_formatter(matplotlib.ticker.ScalarFormatter())

plt.legend()
plt.show()

print('done')

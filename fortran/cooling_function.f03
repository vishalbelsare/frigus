program cooling_function

    use types_and_parameters, only: nlev, energy_lev, vmax, jmax,         &
                                    ntrans, ntemp,                        &
                                    radiative_coeffs, collisional_coeffs, &
                                    Trad, ini, fin

    use energy_levels, only: reading_data_energies
    use radiation, only: reading_data_radiative, stimulated_downwards,      &
                         downward_radiative, stimulated_upwards
    use collisions, only: reading_data_collisions

    type(energy_lev) :: energy
    type(radiative_coeffs) :: a21, b21, b12, r21
    type(collisional_coeffs) :: rr

    call reading_data_energies(energy)
    
    call reading_data_radiative(energy, a21)
    
    call reading_data_collisions(energy, rr)
    
    call stimulated_downwards(energy, a21, b21)
    
    call downward_radiative(energy, Trad, a21, r21)
    
    call stimulated_upwards(energy, a21, b12)
    !print*, b12%M
    
    
    
    
! TEST READING ENERGY LEVELS
!    call reading_data(e)
!    do i = 0, vmax
!       do j = 0, jmax
!           write(6,'(2(i2,2x), e14.8)') i, j, e%en(i,j)
!       enddo
!    enddo

! TEST READING RADIATIVE COEFFICIENTS
!    call reading_data_radiative(a21)
!    print*, a21%ntransrad
!    do ini = 1, nlev
!        do fin = 1, nlev
!           write(6,'(2(i3, 2x), e14.5)') ini, fin, a21%M(ini, fin)
!        enddo
!    enddo

! TEST COUPLES FOR RADIATIVE TRANSITIONS
!    print*, a21%ntransrad, (jmax+1)*15*15*3
!    do l=1,a21%ntransrad
!        print*, a21%couple1r(l), a21%couple2r(l)
!    enddo

! TEST EINSTEIN COEFFICIENTS AND TRANSITIONS
!  do i=1,a21%ntransrad
!     write(6,'(4(i2,2x),e14.5)') a21%vir(i), a21%jir(i), &
!                                 a21%vfr(i), a21%jfr(i), &
!                   a21%M(a21%couple1r(i),a21%couple2r(i))
!  enddo

! TEST COLLISIONAL COEFFICIENTS
! check of the coefficients compared to the read data by François + 
! detailed balance
!    do i=1, ntrans
!       do it=1, ntemp
!          write(6, '(6(i3,2x), 4(e14.5))') rr%couple1c(i),rr%couple2c(i),   &
!                                    rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),&
!                                    rr%temp(it),                            &
!                     rr%matrix(rr%couple1c(i),rr%couple2c(i),it)*1.d6,      &
!                     rr%matrix(rr%couple2c(i),rr%couple1c(i),it)*1.d6,      &
!                          (rr%matrix(rr%couple1c(i),rr%couple2c(i),it)-     &
!                      rr%matrix(rr%couple2c(i),rr%couple1c(i),it))*1.d6/    &
!                      (rr%matrix(rr%couple1c(i),rr%couple2c(i),it)*1.d6)
!    enddo

! TEST DOWNWARDS TRANSITIONS COEFFICIENTS
! do ini = 1, nlev
!    do fin = 1, nlev
!       write(6,'(2(i3, 2x),4(e30.14))') ini, fin,                         &
!                                       a21%M(ini, fin), b21%M(ini, fin),  &
!                                       r21%M(ini, fin),                   & 
!                                       b21%M(fin, ini) 
!    enddo
! enddo

end program cooling_function
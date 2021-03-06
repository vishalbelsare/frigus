module collisions
    use energy_levels
    use types_and_parameters, only: energy_lev, collisional_coeffs, &
                                    it, nlev,       &
                                    vimax, jimax,   &
                                    vfmax, jfmax,   &
                                    ntemp, ntrans,  &
                                    vi, ji, vf, jf, ilique_flag, &
                                    ilipovka_flag
    ! in this module the reading, indexes arrangement and calculations of
    ! stimulated coefficients are performed, starting from the data by
    ! Wolniewicz et al 1998

    type(collisional_coeffs) :: rr
    
    contains

      subroutine reading_data_collisions_lique(e, rr, rr21, rr12)
                 !use energy_levels!: reading_data_energies_stancil, 
                 use types_and_parameters, only: it, nlev, nlev_lique,  &
                                                 vimax, jimax,          &
                                                 vfmax, jfmax,          &
                                                 ntemp, ntrans,         &
                                                 vi, ji, vf, jf,        &
                                                 kb, nc, id_temp
                 type(collisional_coeffs) :: rr, rr21, rr12       ! reaction rate
                 type(energy_lev) :: e
                 integer :: i_final, i_initial

                 real*8 :: dE

                 ! initializing the arrays
                 rr%reading = 0.d0
                 rr%matrix_lique = 0.d0

                 allocate(rr%temp(1:ntemp))
                 rr%temp = [ (i, i=100,ntemp*100,100) ]


                 !do i = 1, ntemp
                 !   print*, 'temperature', i, rr%temp(i)
                 !enddo

                 open (21, file='../../data/Rates_H_H2.dat', status = 'unknown')                 

                !print*, 'ilique_flag in collisions file:', ilique_flag
                !print*, 'ilipovka_flag in collisions file:', ilipovka_flag
                
                ! reading data by lique
                 do i = 1, 10
                    read(21,*)
                 enddo
                ! lique's data
                 do i=1,ntrans
                    read(21,*) rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),      &
                    (rr%reading(rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),it), &
                     it=1,ntemp)
                     vi=rr%vic(i)
                     ji=rr%jic(i)
                     vf=rr%vfc(i)
                     jf=rr%jfc(i)
                     do l=1, nlev_lique
                          if(vi.eq.e%vl_lique(l)) then
                              if(ji.eq.e%jl_lique(l)) then
                                  rr%couple1c(i) = l
                              endif
                          endif
                          if(vf.eq.e%vl_lique(l)) then
                              if(jf.eq.e%jl_lique(l)) then
                                  rr%couple2c(i) = l
                              endif
                          endif
                     enddo
                 enddo
                ! detailed balance implementation (lique)
                 do i=1, ntrans
                     vi=rr%vic(i)
                     ji=rr%jic(i)
                     vf=rr%vfc(i)
                     jf=rr%jfc(i)
                     dE = abs(e%en_lique(vi,ji)-e%en_lique(vf,jf))
                     do it = 1, ntemp
                        rr%matrix_lique(rr%couple1c(i),rr%couple2c(i),it) = &
                                  rr%reading(vi,ji,vf,jf,it)
                        rr21%matrix_lique(rr%couple1c(i),rr%couple2c(i),it) = &
                                  rr%matrix_lique(rr%couple1c(i),rr%couple2c(i),it)
                        rr%matrix_lique(rr%couple2c(i),rr%couple1c(i),it) =       &
                                 dexp(-dE/(kb*rr%temp(it))) * rr%reading(vi,ji,vf,jf,it) &
                                 * ((2.*ji+1.))/(2.*jf+1.)
                        rr12%matrix_lique(rr%couple2c(i),rr%couple1c(i),it) = &
                                 rr%matrix_lique(rr%couple2c(i),rr%couple1c(i),it)
                     enddo
                 enddo
                 !units conversion: cm3 s-1 -> m3 s-1
                 rr%matrix_lique = rr%matrix_lique*1.d-6
                 rr21%matrix_lique = rr21%matrix_lique*1.d-6
                 rr12%matrix_lique = rr12%matrix_lique*1.d-6

      end subroutine reading_data_collisions_lique

      subroutine reading_data_collisions_flower(e, rr, rr21, rr12)
                 !use energy_levels!: reading_data_energies_stancil, 
                 use types_and_parameters, only: it, nlev, nlev_lique,  &
                                                 vimax, jimax,          &
                                                 vfmax, jfmax,          &
                                                 ntemp, ntrans,         &
                                                 vi, ji, vf, jf,        &
                                                 kb, nc, id_temp
                 integer :: ndownwards
                 type(collisional_coeffs) :: rr, rr21, rr12       ! reaction rate
                 type(energy_lev) :: e
                 integer :: i_final, i_initial

                 real*8 :: dE

                 ! initializing the arrays
                 rr%reading = 0.d0
                 rr%matrix_lique = 0.d0

                 allocate(rr%temp(1:ntemp))
                 rr%temp = [ (i, i=100,ntemp*100,100) ]

                 !do i = 1, ntemp
                 !   print*, 'temperature', i, rr%temp(i)
                 !enddo

                 open (19, file='../../data/wrathmall/Rates_H_H2_flower_new.dat', status = 'unknown')                 
                 open (20, file='../../data/wrathmall/Rates_H_H2_flower_new_downwards.dat', status = 'unknown')

                 !print*, 'ilique_flag in collisions file:', ilique_flag
                 !print*, 'ilipovka_flag in collisions file:', ilipovka_flag
                
                 ndownwards = 0
                 do i = 1, 10
                    write(20, *)
                 enddo
                ! reading data and writing only downwards
                 do i = 1, 10   ! data by wrathmall
                   read(19,*)
                 enddo
                 do i=1,ntrans
                    read(19,*) rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),      &
                    (rr%reading(rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),it), &
                    it=1,ntemp)
                    vi=rr%vic(i)
                    ji=rr%jic(i)
                    vf=rr%vfc(i)
                    jf=rr%jfc(i)
                    if(e%en_lique(vi,ji)-e%en_lique(vf,jf).gt.0.d0) then 
                         ndownwards = ndownwards + 1
                         write(20, '(4i3, 1x, 60(e14.4,1x))') vi, ji, vf, jf, &
                         (rr%reading(rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),it), &
                         it=1,ntemp)
                    endif
                 enddo
                 write(20, *)
                 rewind(20)
                ! reading data
                 do i=1,10   ! data by wrathmall
                    read(20,*)
                 enddo
                 do i=1, ndownwards
                    read(20,*) rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),      &
                    (rr%reading(rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),it), &
                     it=1,ntemp)
                    vi=rr%vic(i)
                    ji=rr%jic(i)
                    vf=rr%vfc(i)
                    jf=rr%jfc(i)
                    print*, vi, ji, vf, jf
                    do l=1, nlev_lique
                         if(vi.eq.e%vl_lique(l)) then
                             if(ji.eq.e%jl_lique(l)) then
                                 rr%couple1c(i) = l
                             endif
                         endif
                         if(vf.eq.e%vl_lique(l)) then
                             if(jf.eq.e%jl_lique(l)) then
                                rr%couple2c(i) = l
                             endif
                         endif
                     enddo
                 enddo
                 ! detailed balance implementation (wrathmall)
                 do i= 1, ndownwards !ntrans
                    vi=rr%vic(i)
                    ji=rr%jic(i)
                    vf=rr%vfc(i)
                    jf=rr%jfc(i)
                    dE = abs(e%en_lique(vi,ji)-e%en_lique(vf,jf))
                    do it = 1, ntemp
                         rr%matrix_lique(rr%couple1c(i),rr%couple2c(i),it) = &
                             rr%reading(vi,ji,vf,jf,it)
                         rr21%matrix_lique(rr%couple1c(i),rr%couple2c(i),it) = &
                                rr%matrix_lique(rr%couple1c(i),rr%couple2c(i),it)
                         rr%matrix_lique(rr%couple2c(i),rr%couple1c(i),it) =       &
                                 dexp(-dE/(kb*rr%temp(it))) * rr%reading(vi,ji,vf,jf,it) &
                                 * ((2.*ji+1.))/(2.*jf+1.)
                         rr12%matrix_lique(rr%couple2c(i),rr%couple1c(i),it) = &
                                 rr%matrix_lique(rr%couple2c(i),rr%couple1c(i),it)
                     enddo
                 enddo
                 !units conversion: cm3 s-1 -> m3 s-1
                 rr%matrix_lique = rr%matrix_lique*1.d-6
                 rr21%matrix_lique = rr21%matrix_lique*1.d-6
                 rr12%matrix_lique = rr12%matrix_lique*1.d-6


      end subroutine reading_data_collisions_flower

      subroutine reading_data_collisions_lipovka(e, rr, rr21, rr12)
                 !use energy_levels!: reading_data_energies_stancil, 
                 use types_and_parameters, only: it, nlev, nlev_lique,  &
                                                 vimax, jimax,          &
                                                 vfmax, jfmax,          &
                                                 ntemp, ntrans,         &
                                                 vi, ji, vf, jf,        &
                                                 kb, nc, id_temp

                 integer :: ndownwards_lipovka
                 type(collisional_coeffs) :: rr, rr21, rr12       ! reaction rate
                 type(energy_lev) :: e
                 integer :: i_final, i_initial

                 real*8 :: dE

                 ! initializing the arrays
                 rr%reading = 0.d0
                 rr%matrix_lique = 0.d0

                 allocate(rr%temp(1:ntemp))
                 rr%temp = [ (i, i=100, 2000, 20) ]

                 !do i = 1, ntemp
                 !   print*, 'temperature', i, rr%temp(i)
                 !enddo


                 open (22, file='../../data/read/lipovka/Rates_H_HD.dat', status = 'unknown')
                 ! open (23, in the part concerning the lipovka data

                 print*, 'ilique_flag in collisions file:', ilique_flag
                 print*, 'ilipovka_flag in collisions file:', ilipovka_flag
                

                ! reading data used by lipovka (by flower and roueff) and transforming them into the format by wrathmall and lique
                 do i = 1, 15
                    read(22,*)
                 enddo
                 do it = 1, ntemp
                    read(22,*) a
                    read(22,'(a80)') bc
                    print*, a
                     do i_final = 1, 10
                       read(22,*) (rr%reading(0, i_initial-1, 0, i_final-1, it), i_initial= 1, 10)
                       !print*, i_final-1, i_initial-1
                       !print*, rr%reading(0,i_initial,0,i_final,it)
                     enddo
                     read(22,*)
                     read(22,*)
                     read(22,*)
                 enddo
                 ! rewriting on file in the same format by Wrathmall and Lique
                 open (23, file='../../data/read/lipovka/Rates_H_HD_new.dat', status = 'unknown')
                 ndownwards_lipovka = 0
                 do i_initial = 0, 9
                   do i_final = 0, 9
                    if(e%en_lique(0,i_initial)-e%en_lique(0,i_final).ge. 0.d0) then
                    ndownwards_lipovka = ndownwards_lipovka + 1
                      write(23, ('(4(i2, x), 96(ES23.15, x))')) 0,                                     &
                                                         i_initial,                                  &
                                                         0,                                            &
                                                         i_final,                                    &
                                                         (rr%reading(0,i_initial,0,i_final,it),    &
                                                         it = 1, ntemp)
                    endif
                   enddo
                 enddo
                 rewind(23)
                 ! finished with the restyled datafile
                  do i = 1, ndownwards_lipovka
                      read(23,*) rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),      &
                      (rr%reading(rr%vic(i),rr%jic(i),rr%vfc(i),rr%jfc(i),it), &
                      it=1,ntemp)
                      vi=rr%vic(i)
                      ji=rr%jic(i)
                      vf=rr%vfc(i)
                      jf=rr%jfc(i)
                      !print*, vi, ji, vf, jf
                      do l = 1, nlev_lique
                          if(vi.eq.e%vl_lique(l)) then
                              if(ji.eq.e%jl_lique(l)) then
                                  rr%couple1c(i) = l
                              endif
                          endif
                          if(vf.eq.e%vl_lique(l)) then
                              if(jf.eq.e%jl_lique(l)) then
                                  rr%couple2c(i) = l
                              endif
                          endif
                      enddo
                  enddo
                  ! detailed balance implementation (lique)
                  do i= 1, ndownwards_lipovka
                        vi=rr%vic(i)
                        ji=rr%jic(i)
                        vf=rr%vfc(i)
                        jf=rr%jfc(i)
                        dE = abs(e%en_lique(vi,ji)-e%en_lique(vf,jf))
                            do it = 1, ntemp
                            rr%matrix_lique(rr%couple1c(i),rr%couple2c(i),it) = &
                                            rr%reading(vi,ji,vf,jf,it)
                            rr21%matrix_lique(rr%couple1c(i),rr%couple2c(i),it) = &
                                rr%matrix_lique(rr%couple1c(i),rr%couple2c(i),it)
                            rr%matrix_lique(rr%couple2c(i),rr%couple1c(i),it) =       &
                                dexp(-dE/(kb*rr%temp(it))) * rr%reading(vi,ji,vf,jf,it) &
                                * ((2.*ji+1.))/(2.*jf+1.)
                            rr12%matrix_lique(rr%couple2c(i),rr%couple1c(i),it) = &
                                rr%matrix_lique(rr%couple2c(i),rr%couple1c(i),it)
                            enddo
                        enddo

                 !units conversion: cm3 s-1 -> m3 s-1
                 rr%matrix_lique = rr%matrix_lique*1.d-6
                 rr21%matrix_lique = rr21%matrix_lique*1.d-6
                 rr12%matrix_lique = rr12%matrix_lique*1.d-6


      end subroutine reading_data_collisions_lipovka


    end module collisions



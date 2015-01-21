   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of bcsymm in reverse (adjoint) mode (with options i4 dr8 r8 noISIZE):
   !   gradient     of useful results: *rev *p *w *rlv *(*bcdata.norm)
   !   with respect to varying inputs: *rev *p *w *rlv *(*bcdata.norm)
   !   Plus diff mem management of: rev:in p:in gamma:in w:in rlv:in
   !                bcdata:in *bcdata.norm:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          bcSymm.f90                                      *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 03-07-2003                                      *
   !      * Last modified: 06-12-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE BCSYMM_B(secondhalo)
   !
   !      ******************************************************************
   !      *                                                                *
   !      * bcSymm applies the symmetry boundary conditions to a block.    *
   !      * It is assumed that the pointers in blockPointers are already   *
   !      * set to the correct block on the correct grid level.            *
   !      *                                                                *
   !      * In case also the second halo must be set the loop over the     *
   !      * boundary subfaces is executed twice. This is the only correct  *
   !      * way in case the block contains only 1 cell between two         *
   !      * symmetry planes, i.e. a 2D problem.                            *
   !      *                                                                *
   !      ******************************************************************
   !
   USE BLOCKPOINTERS
   USE BCTYPES
   USE CONSTANTS
   USE FLOWVARREFSTATE
   USE ITERATION
   IMPLICIT NONE
   !
   !      Subroutine arguments.
   !
   LOGICAL, INTENT(IN) :: secondhalo
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: kk, mm, nn, i, j, l
   REAL(kind=realtype) :: vn, nnx, nny, nnz
   REAL(kind=realtype) :: vnd
   REAL(kind=realtype), DIMENSION(imaxdim, jmaxdim, nw) :: ww1, ww2
   REAL(kind=realtype), DIMENSION(imaxdim, jmaxdim, nw) :: ww1d, ww2d
   REAL(kind=realtype), DIMENSION(imaxdim, jmaxdim) :: pp1, pp2
   REAL(kind=realtype), DIMENSION(imaxdim, jmaxdim) :: pp1d, pp2d
   REAL(kind=realtype), DIMENSION(imaxdim, jmaxdim) :: gamma1, gamma2
   REAL(kind=realtype), DIMENSION(imaxdim, jmaxdim) :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(imaxdim, jmaxdim) :: rlv1d, rlv2d
   REAL(kind=realtype), DIMENSION(imaxdim, jmaxdim) :: rev1, rev2
   REAL(kind=realtype), DIMENSION(imaxdim, jmaxdim) :: rev1d, rev2d
   INTEGER :: branch
   INTEGER :: ad_from
   INTEGER :: ad_to
   INTEGER :: ad_from0
   INTEGER :: ad_to0
   REAL(kind=realtype) :: tempd
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Set the value of kk; kk == 0 means only single halo, kk == 1
   ! double halo.
   kk = 0
   IF (secondhalo) kk = 1
   ! Loop over the number of times the halo computation must be done.
   nhalo:DO mm=0,kk
   ! Loop over the boundary condition subfaces of this block.
   bocos:DO nn=1,nbocos
   ! Check for symmetry boundary condition.
   IF (bctype(nn) .EQ. symm) THEN
   ! Nullify the pointers, because some compilers require that.
   !nullify(ww1, ww2, pp1, pp2, rlv1, rlv2, rev1, rev2)
   ! Set the pointers to the correct subface.
   CALL PUSHREAL8ARRAY(ww2, imaxdim*jmaxdim*nw)
   CALL SETBCPOINTERSBWD(nn, ww1, ww2, pp1, pp2, rlv1, rlv2, &
   &                          rev1, rev2, mm)
   ! Set the additional pointers for gamma1 and gamma2.
   ad_from0 = bcdata(nn)%jcbeg
   ! Loop over the generic subface to set the state in the
   ! halo cells.
   DO j=ad_from0,bcdata(nn)%jcend
   ad_from = bcdata(nn)%icbeg
   DO i=ad_from,bcdata(nn)%icend
   ! Store the three components of the unit normal a
   ! bit easier.
   ! Replace with actual BCData - Peter Lyu
   !nnx = BCData(nn)%norm(i,j,1)
   !nny = BCData(nn)%norm(i,j,2)
   !nnz = BCData(nn)%norm(i,j,3)
   ! Determine twice the normal velocity component,
   ! which must be substracted from the donor velocity
   ! to obtain the halo velocity.
   CALL PUSHREAL8(vn)
   vn = two*(ww2(i, j, ivx)*bcdata(nn)%norm(i, j, 1)+ww2(i, j, &
   &             ivy)*bcdata(nn)%norm(i, j, 2)+ww2(i, j, ivz)*bcdata(nn)%&
   &             norm(i, j, 3))
   ! Determine the flow variables in the halo cell.
   ww1(i, j, irho) = ww2(i, j, irho)
   ww1(i, j, ivx) = ww2(i, j, ivx) - vn*bcdata(nn)%norm(i, j, 1&
   &             )
   ww1(i, j, ivy) = ww2(i, j, ivy) - vn*bcdata(nn)%norm(i, j, 2&
   &             )
   ww1(i, j, ivz) = ww2(i, j, ivz) - vn*bcdata(nn)%norm(i, j, 3&
   &             )
   ww1(i, j, irhoe) = ww2(i, j, irhoe)
   ! Simply copy the turbulent variables.
   DO l=nt1mg,nt2mg
   ww1(i, j, l) = ww2(i, j, l)
   END DO
   ! Set the pressure and gamma and possibly the
   ! laminar and eddy viscosity in the halo.
   pp1(i, j) = pp2(i, j)
   IF (viscous) THEN
   rlv1(i, j) = rlv2(i, j)
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHCONTROL1B(1)
   END IF
   IF (eddymodel) THEN
   rev1(i, j) = rev2(i, j)
   CALL PUSHCONTROL1B(1)
   ELSE
   CALL PUSHCONTROL1B(0)
   END IF
   END DO
   CALL PUSHINTEGER4(i - 1)
   CALL PUSHINTEGER4(ad_from)
   END DO
   CALL PUSHINTEGER4(j - 1)
   CALL PUSHINTEGER4(ad_from0)
   ! deallocation all pointer
   CALL PUSHREAL8ARRAY(rlv, SIZE(rlv, 1)*SIZE(rlv, 2)*SIZE(rlv, 3))
   CALL PUSHREAL8ARRAY(w, SIZE(w, 1)*SIZE(w, 2)*SIZE(w, 3)*SIZE(w, &
   &                     4))
   CALL RESETBCPOINTERSBWD(nn, ww1, ww2, pp1, pp2, rlv1, rlv2, &
   &                            rev1, rev2, mm)
   CALL PUSHCONTROL1B(1)
   ELSE
   CALL PUSHCONTROL1B(0)
   END IF
   END DO bocos
   END DO nhalo
   DO mm=kk,0,-1
   DO nn=nbocos,1,-1
   CALL POPCONTROL1B(branch)
   IF (branch .NE. 0) THEN
   CALL POPREAL8ARRAY(w, SIZE(w, 1)*SIZE(w, 2)*SIZE(w, 3)*SIZE(w, 4&
   &                    ))
   CALL POPREAL8ARRAY(rlv, SIZE(rlv, 1)*SIZE(rlv, 2)*SIZE(rlv, 3))
   CALL RESETBCPOINTERSBWD_B(nn, ww1, ww1d, ww2, ww2d, pp1, pp1d, &
   &                           pp2, pp2d, rlv1, rlv1d, rlv2, rlv2d, rev1, &
   &                           rev1d, rev2, rev2d, mm)
   CALL POPINTEGER4(ad_from0)
   CALL POPINTEGER4(ad_to0)
   DO j=ad_to0,ad_from0,-1
   CALL POPINTEGER4(ad_from)
   CALL POPINTEGER4(ad_to)
   DO i=ad_to,ad_from,-1
   CALL POPCONTROL1B(branch)
   IF (branch .NE. 0) THEN
   rev2d(i, j) = rev2d(i, j) + rev1d(i, j)
   rev1d(i, j) = 0.0_8
   END IF
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   rlv2d(i, j) = rlv2d(i, j) + rlv1d(i, j)
   rlv1d(i, j) = 0.0_8
   END IF
   pp2d(i, j) = pp2d(i, j) + pp1d(i, j)
   pp1d(i, j) = 0.0_8
   DO l=nt2mg,nt1mg,-1
   ww2d(i, j, l) = ww2d(i, j, l) + ww1d(i, j, l)
   ww1d(i, j, l) = 0.0_8
   END DO
   ww2d(i, j, irhoe) = ww2d(i, j, irhoe) + ww1d(i, j, irhoe)
   ww1d(i, j, irhoe) = 0.0_8
   ww2d(i, j, ivz) = ww2d(i, j, ivz) + ww1d(i, j, ivz)
   vnd = -(bcdata(nn)%norm(i, j, 3)*ww1d(i, j, ivz))
   bcdatad(nn)%norm(i, j, 3) = bcdatad(nn)%norm(i, j, 3) - vn*&
   &             ww1d(i, j, ivz)
   ww1d(i, j, ivz) = 0.0_8
   ww2d(i, j, ivy) = ww2d(i, j, ivy) + ww1d(i, j, ivy)
   vnd = vnd - bcdata(nn)%norm(i, j, 2)*ww1d(i, j, ivy)
   bcdatad(nn)%norm(i, j, 2) = bcdatad(nn)%norm(i, j, 2) - vn*&
   &             ww1d(i, j, ivy)
   ww1d(i, j, ivy) = 0.0_8
   ww2d(i, j, ivx) = ww2d(i, j, ivx) + ww1d(i, j, ivx)
   vnd = vnd - bcdata(nn)%norm(i, j, 1)*ww1d(i, j, ivx)
   bcdatad(nn)%norm(i, j, 1) = bcdatad(nn)%norm(i, j, 1) - vn*&
   &             ww1d(i, j, ivx)
   ww1d(i, j, ivx) = 0.0_8
   ww2d(i, j, irho) = ww2d(i, j, irho) + ww1d(i, j, irho)
   ww1d(i, j, irho) = 0.0_8
   CALL POPREAL8(vn)
   tempd = two*vnd
   ww2d(i, j, ivx) = ww2d(i, j, ivx) + bcdata(nn)%norm(i, j, 1)&
   &             *tempd
   bcdatad(nn)%norm(i, j, 1) = bcdatad(nn)%norm(i, j, 1) + ww2(&
   &             i, j, ivx)*tempd
   ww2d(i, j, ivy) = ww2d(i, j, ivy) + bcdata(nn)%norm(i, j, 2)&
   &             *tempd
   bcdatad(nn)%norm(i, j, 2) = bcdatad(nn)%norm(i, j, 2) + ww2(&
   &             i, j, ivy)*tempd
   ww2d(i, j, ivz) = ww2d(i, j, ivz) + bcdata(nn)%norm(i, j, 3)&
   &             *tempd
   bcdatad(nn)%norm(i, j, 3) = bcdatad(nn)%norm(i, j, 3) + ww2(&
   &             i, j, ivz)*tempd
   END DO
   END DO
   CALL POPREAL8ARRAY(ww2, imaxdim*jmaxdim*nw)
   CALL SETBCPOINTERSBWD_B(nn, ww1, ww1d, ww2, ww2d, pp1, pp1d, pp2&
   &                         , pp2d, rlv1, rlv1d, rlv2, rlv2d, rev1, rev1d&
   &                         , rev2, rev2d, mm)
   END IF
   END DO
   END DO
   END SUBROUTINE BCSYMM_B

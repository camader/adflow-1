!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
!  
!  Differentiation of bcfarfieldadj in reverse (adjoint) mode:
!   gradient, with respect to input variables: winfadj padj pinfcorradj
!                wadj normadj
!   of linear combination of output variables: padj pinfcorradj
!                wadj normadj
!
!      ******************************************************************
!      *                                                                *
!      * File:          bcFarfieldAdj.f90                               *
!      * Author:        Edwin van der Weide                             *
!      *                Seongim Choi,C.A.(Sandy) Mader                  *
!      * Starting date: 03-21-2006                                      *
!      * Last modified: 04-23-2008                                      *
!      *                                                                *
!      ******************************************************************
!
SUBROUTINE BCFARFIELDADJ_B(secondhalo, winfadj, winfadjb, pinfcorradj, &
&  pinfcorradjb, wadj, wadjb, padj, padjb, siadj, sjadj, skadj, normadj&
&  , normadjb, rfaceadj, icell, jcell, kcell)
  USE bctypes
  USE blockpointers, ONLY : bcdata, nbocos, bctype, bcfaceid, gamma, &
&  il, jl, kl, w, p
  USE constants
  USE flowvarrefstate
  USE iteration
  IMPLICIT NONE
  INTEGER(KIND=INTTYPE) :: icell, jcell, kcell
  REAL(KIND=REALTYPE), DIMENSION(nbocos, -2:2, -2:2, 3), INTENT(IN) :: &
&  normadj
  REAL(KIND=REALTYPE) :: normadjb(nbocos, -2:2, -2:2, 3)
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, -2:2), INTENT(IN) :: padj
  REAL(KIND=REALTYPE) :: padjb(-2:2, -2:2, -2:2)
  REAL(KIND=REALTYPE) :: pinfcorradj, pinfcorradjb
  REAL(KIND=REALTYPE), DIMENSION(nbocos, -2:2, -2:2), INTENT(IN) :: &
&  rfaceadj
  LOGICAL, INTENT(IN) :: secondhalo
  REAL(KIND=REALTYPE), DIMENSION(-3:2, -3:2, -3:2, 3), INTENT(IN) :: &
&  siadj
  REAL(KIND=REALTYPE), DIMENSION(-3:2, -3:2, -3:2, 3), INTENT(IN) :: &
&  sjadj
  REAL(KIND=REALTYPE), DIMENSION(-3:2, -3:2, -3:2, 3), INTENT(IN) :: &
&  skadj
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, -2:2, nw), INTENT(IN) :: &
&  wadj
  REAL(KIND=REALTYPE) :: wadjb(-2:2, -2:2, -2:2, nw)
  REAL(KIND=REALTYPE), DIMENSION(nw), INTENT(IN) :: winfadj
  REAL(KIND=REALTYPE) :: winfadjb(nw)
  REAL(KIND=REALTYPE) :: ac1, ac1b, ac2, ac2b, factk, gm1, gm53, ovgm1
  INTEGER :: ad_from, ad_from0, ad_to, ad_to0, branch
  REAL(KIND=REALTYPE) :: cc, ccb, cf, cfb, qnf, qnfb, qq, sf, sfb, &
&  tempb1, tempb2, uf, ufb, vf, vfb, wf, wfb
  LOGICAL :: computebc
  INTEGER(KIND=INTTYPE) :: ibbeg, ibend, jbbeg, jbend, kbbeg, kbend
  INTEGER(KIND=INTTYPE) :: icbeg, icend, jcbeg, jcend, kcbeg, kcend
  INTEGER(KIND=INTTYPE) :: ioffset, joffset, koffset
  INTEGER(KIND=INTTYPE) :: i, ii, j, jj, l
  INTEGER(KIND=INTTYPE) :: isbeg, isend, jsbeg, jsend, ksbeg, ksend
  INTEGER(KIND=INTTYPE) :: nn
  REAL(KIND=REALTYPE) :: nnx, nnxb, nny, nnyb, nnz, nnzb
  REAL(KIND=REALTYPE) :: padj0(-2:2, -2:2), padj0b(-2:2, -2:2), padj1(-2&
&  :2, -2:2), padj1b(-2:2, -2:2)
  REAL(KIND=REALTYPE) :: padj2(-2:2, -2:2), padj2b(-2:2, -2:2), padj3(-2&
&  :2, -2:2), padj3b(-2:2, -2:2)
  REAL(KIND=REALTYPE) :: revadj1(-2:2, -2:2), revadj2(-2:2, -2:2)
  REAL(KIND=REALTYPE) :: rface
  REAL(KIND=REALTYPE) :: revadj(-2:2, -2:2, -2:2), rlvadj(-2:2, -2:2, -2&
&  :2)
  REAL(KIND=REALTYPE) :: rlvadj1(-2:2, -2:2), rlvadj2(-2:2, -2:2)
  REAL(KIND=REALTYPE) :: c0, c0b, qn0, qn0b, r0, r0b, s0, s0b, tempb, u0&
&  , u0b, v0, v0b, vn0, w0, w0b
  REAL(KIND=REALTYPE) :: tempb3, tempb4, tmp, tmp0, tmp0b, tmpb, wadj0(-&
&  2:2, -2:2, nw), wadj0b(-2:2, -2:2, nw), wadj1(-2:2, -2:2, nw), wadj1b&
&  (-2:2, -2:2, nw)
  REAL(KIND=REALTYPE) :: wadj2(-2:2, -2:2, nw), wadj2b(-2:2, -2:2, nw), &
&  wadj3(-2:2, -2:2, nw), wadj3b(-2:2, -2:2, nw)
  REAL(KIND=REALTYPE) :: ce, ceb, qne, qneb, re, reb, tempb0, ue, ueb, &
&  ve, veb, we, web
  INTRINSIC SQRT
!
!      ******************************************************************
!      *                                                                *
!      * bcFarfieldAdj applies the farfield boundary condition to       *
!      * subface nn of the block to which the pointers in blockPointers *
!      * currently point.                                               *
!      *                                                                *
!      ******************************************************************
!
! irho,ivx,ivy,ivz
! gammaInf, wInf, pInfCorr
!
!      Subroutine arguments.
!
! it's not needed anymore w/ normAdj
!       integer(kind=intType), intent(in) :: icBeg, icEnd, jcBeg, jcEnd
!       integer(kind=intType), intent(in) :: iOffset, jOffset
!  real(kind=realType), dimension(-2:2,-2:2,-2:2,3), intent(in) :: &
!       siAdj, sjAdj, skAdj
!real(kind=realType), dimension(nBocos,-2:2,-2:2,3), intent(in) :: normAdj
!
!      Local variables.
!
!
!      Interfaces
!
!
!      ******************************************************************
!      *                                                                *
!      * Begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
! Some constants needed to compute the riemann invariants.
  gm1 = gammainf - one
  ovgm1 = one/gm1
  gm53 = gammainf - five*third
  factk = -(ovgm1*gm53)
! Compute the three velocity components, the speed of sound and
! the entropy of the free stream.
  r0 = one/winfadj(irho)
  u0 = winfadj(ivx)
  v0 = winfadj(ivy)
  w0 = winfadj(ivz)
  c0 = SQRT(gammainf*pinfcorradj*r0)
  s0 = winfadj(irho)**gammainf/pinfcorradj
! Loop over the boundary condition subfaces of this block.
bocos:DO nn=1,nbocos
    CALL PUSHINTEGER4(kbend)
    CALL PUSHINTEGER4(jbend)
    CALL PUSHINTEGER4(ibend)
    CALL PUSHINTEGER4(kbbeg)
    CALL PUSHINTEGER4(jbbeg)
    CALL PUSHINTEGER4(ibbeg)
    CALL PUSHINTEGER4(ksend)
    CALL PUSHINTEGER4(jsend)
    CALL PUSHINTEGER4(isend)
    CALL PUSHINTEGER4(ksbeg)
    CALL PUSHINTEGER4(jsbeg)
    CALL PUSHINTEGER4(isbeg)
    CALL CHECKOVERLAPADJ(nn, icell, jcell, kcell, isbeg, jsbeg, ksbeg, &
&                   isend, jsend, ksend, ibbeg, jbbeg, kbbeg, ibend, &
&                   jbend, kbend, computebc)
    IF (computebc) THEN
! Check for farfield boundary conditions.
      IF (bctype(nn) .EQ. farfield) THEN
        CALL PUSHBOOLEAN(secondhalo)
        CALL PUSHINTEGER4(jcend)
        CALL PUSHINTEGER4(icend)
        CALL PUSHINTEGER4(jcbeg)
        CALL PUSHINTEGER4(icbeg)
        CALL PUSHINTEGER4(joffset)
        CALL PUSHINTEGER4(ioffset)
        CALL PUSHREAL8ARRAY(padj2, 5**2)
        CALL PUSHREAL8ARRAY(padj1, 5**2)
        CALL PUSHREAL8ARRAY(wadj2, 5**2*nw)
        CALL PUSHREAL8ARRAY(wadj1, 5**2*nw)
        CALL EXTRACTBCSTATESADJ(nn, wadj, padj, wadj0, wadj1, wadj2, &
&                          wadj3, padj0, padj1, padj2, padj3, rlvadj, &
&                          revadj, rlvadj1, rlvadj2, revadj1, revadj2, &
&                          ioffset, joffset, koffset, icell, jcell, &
&                          kcell, isbeg, jsbeg, ksbeg, isend, jsend, &
&                          ksend, ibbeg, jbbeg, kbbeg, ibend, jbend, &
&                          kbend, icbeg, jcbeg, icend, jcend, secondhalo&
&                         )
        ad_from = jcbeg
! Loop over the generic subface to set the state in the
! halo cells.
        DO j=ad_from,jcend
          ad_from0 = icbeg
          DO i=ad_from0,icend
            CALL PUSHINTEGER4(ii)
            ii = i - ioffset
            CALL PUSHINTEGER4(jj)
            jj = j - joffset
!BCData(nn)%rface(i,j)
            rface = rfaceadj(nn, ii, jj)
            CALL PUSHREAL8(nnx)
! Store the three components of the unit normal a
! bit easier.
            nnx = normadj(nn, ii, jj, 1)
            CALL PUSHREAL8(nny)
            nny = normadj(nn, ii, jj, 2)
            CALL PUSHREAL8(nnz)
            nnz = normadj(nn, ii, jj, 3)
            CALL PUSHREAL8(qn0)
! Compute the normal velocity of the free stream and
! substract the normal velocity of the mesh.
            qn0 = u0*nnx + v0*nny + w0*nnz
            vn0 = qn0 - rface
            CALL PUSHREAL8(re)
! Compute the three velocity components, the normal
! velocity and the speed of sound of the current state
! in the internal cell.
            re = one/wadj2(ii, jj, irho)
            CALL PUSHREAL8(ue)
            ue = wadj2(ii, jj, ivx)
            CALL PUSHREAL8(ve)
            ve = wadj2(ii, jj, ivy)
            CALL PUSHREAL8(we)
            we = wadj2(ii, jj, ivz)
            CALL PUSHREAL8(qne)
            qne = ue*nnx + ve*nny + we*nnz
            ce = SQRT(gammainf*padj2(ii, jj)*re)
! Compute the new values of the riemann invariants in
! the halo cell. Either the value in the internal cell
! is taken (positive sign of the corresponding
! eigenvalue) or the free stream value is taken
! (otherwise).
            IF (vn0 .GT. -c0) THEN
! Outflow or subsonic inflow.
              ac1 = qne + two*ovgm1*ce
              CALL PUSHINTEGER4(0)
            ELSE
! Supersonic inflow.
              ac1 = qn0 + two*ovgm1*c0
              CALL PUSHINTEGER4(1)
            END IF
            IF (vn0 .GT. c0) THEN
! Supersonic outflow.
              ac2 = qne - two*ovgm1*ce
              CALL PUSHINTEGER4(0)
            ELSE
! Inflow or subsonic outflow.
              ac2 = qn0 - two*ovgm1*c0
              CALL PUSHINTEGER4(1)
            END IF
            CALL PUSHREAL8(qnf)
            qnf = half*(ac1+ac2)
            CALL PUSHREAL8(cf)
            cf = fourth*(ac1-ac2)*gm1
            IF (vn0 .GT. zero) THEN
              CALL PUSHREAL8(uf)
! Outflow.
              uf = ue + (qnf-qne)*nnx
              CALL PUSHREAL8(vf)
              vf = ve + (qnf-qne)*nny
              CALL PUSHREAL8(wf)
              wf = we + (qnf-qne)*nnz
              CALL PUSHREAL8(sf)
              sf = wadj2(ii, jj, irho)**gammainf/padj2(ii, jj)
              DO l=nt1mg,nt2mg
                CALL PUSHREAL8(wadj1(ii, jj, l))
                wadj1(ii, jj, l) = wadj2(ii, jj, l)
              END DO
              CALL PUSHINTEGER4(0)
            ELSE
              CALL PUSHREAL8(uf)
! Inflow
              uf = u0 + (qnf-qn0)*nnx
              CALL PUSHREAL8(vf)
              vf = v0 + (qnf-qn0)*nny
              CALL PUSHREAL8(wf)
              wf = w0 + (qnf-qn0)*nnz
              CALL PUSHREAL8(sf)
              sf = s0
              DO l=nt1mg,nt2mg
                CALL PUSHREAL8(wadj1(ii, jj, l))
                wadj1(ii, jj, l) = winfadj(l)
              END DO
              CALL PUSHINTEGER4(1)
            END IF
            CALL PUSHREAL8(cc)
! Compute the density, velocity and pressure in the
! halo cell.
            cc = cf*cf/gammainf
            CALL PUSHREAL8(wadj1(ii, jj, irho))
            wadj1(ii, jj, irho) = (sf*cc)**ovgm1
            CALL PUSHREAL8(wadj1(ii, jj, ivx))
            wadj1(ii, jj, ivx) = uf
            CALL PUSHREAL8(wadj1(ii, jj, ivy))
            wadj1(ii, jj, ivy) = vf
            CALL PUSHREAL8(wadj1(ii, jj, ivz))
            wadj1(ii, jj, ivz) = wf
            padj1(ii, jj) = wadj1(ii, jj, irho)*cc
! Compute the total energy.
            tmp = ovgm1*padj1(ii, jj) + half*wadj1(ii, jj, irho)*(uf**2+&
&              vf**2+wf**2)
            CALL PUSHREAL8(wadj1(ii, jj, irhoe))
            wadj1(ii, jj, irhoe) = tmp
            IF (kpresent) THEN
              tmp0 = wadj1(ii, jj, irhoe) - factk*wadj1(ii, jj, irho)*&
&                wadj1(ii, jj, itu1)
              CALL PUSHREAL8(wadj1(ii, jj, irhoe))
              wadj1(ii, jj, irhoe) = tmp0
              CALL PUSHINTEGER4(2)
            ELSE
              CALL PUSHINTEGER4(1)
            END IF
          END DO
          CALL PUSHINTEGER4(i - 1)
          CALL PUSHINTEGER4(ad_from0)
        END DO
        CALL PUSHINTEGER4(j - 1)
        CALL PUSHINTEGER4(ad_from)
!
!        Input the viscous effects - rlv1(), and rev1()
!
! Extrapolate the state vectors in case a second halo
! is needed.
        IF (secondhalo) THEN
          CALL PUSHREAL8ARRAY(padj0, 5**2)
          CALL PUSHREAL8ARRAY(wadj0, 5**2*nw)
          CALL EXTRAPOLATE2NDHALOADJ(nn, icbeg, icend, jcbeg, jcend, &
&                               ioffset, joffset, wadj0, wadj1, wadj2, &
&                               padj0, padj1, padj2)
          CALL PUSHINTEGER4(1)
        ELSE
          CALL PUSHINTEGER4(0)
        END IF
        CALL REPLACEBCSTATESADJ(nn, wadj0, wadj1, wadj2, wadj3, padj0, &
&                          padj1, padj2, padj3, rlvadj1, rlvadj2, &
&                          revadj1, revadj2, icell, jcell, kcell, wadj, &
&                          padj, rlvadj, revadj, secondhalo)
        CALL PUSHINTEGER4(3)
      ELSE
        CALL PUSHINTEGER4(2)
      END IF
    ELSE
      CALL PUSHINTEGER4(1)
    END IF
  END DO bocos
  winfadjb(1:nw) = 0.0
  v0b = 0.0
  s0b = 0.0
  padj0b(-2:2, -2:2) = 0.0
  padj1b(-2:2, -2:2) = 0.0
  padj2b(-2:2, -2:2) = 0.0
  c0b = 0.0
  w0b = 0.0
  wadj0b(-2:2, -2:2, 1:nw) = 0.0
  wadj1b(-2:2, -2:2, 1:nw) = 0.0
  wadj2b(-2:2, -2:2, 1:nw) = 0.0
  u0b = 0.0
  DO nn=nbocos,1,-1
    CALL POPINTEGER4(branch)
    IF (.NOT.branch .LT. 3) THEN
      CALL REPLACEBCSTATESADJ_B(nn, wadj0, wadj0b, wadj1, wadj1b, wadj2&
&                          , wadj3, padj0, padj0b, padj1, padj1b, padj2&
&                          , padj3, rlvadj1, rlvadj2, revadj1, revadj2, &
&                          icell, jcell, kcell, wadj, wadjb, padj, padjb&
&                          , rlvadj, revadj, secondhalo)
      CALL POPINTEGER4(branch)
      IF (.NOT.branch .LT. 1) THEN
        CALL POPREAL8ARRAY(wadj0, 5**2*nw)
        CALL POPREAL8ARRAY(padj0, 5**2)
        CALL EXTRAPOLATE2NDHALOADJ_B(nn, icbeg, icend, jcbeg, jcend, &
&                               ioffset, joffset, wadj0, wadj0b, wadj1, &
&                               wadj1b, wadj2, wadj2b, padj0, padj0b, &
&                               padj1, padj1b, padj2, padj2b)
      END IF
      CALL POPINTEGER4(ad_from)
      CALL POPINTEGER4(ad_to)
      DO j=ad_to,ad_from,-1
        CALL POPINTEGER4(ad_from0)
        CALL POPINTEGER4(ad_to0)
        DO i=ad_to0,ad_from0,-1
          CALL POPINTEGER4(branch)
          IF (.NOT.branch .LT. 2) THEN
            CALL POPREAL8(wadj1(ii, jj, irhoe))
            tmp0b = wadj1b(ii, jj, irhoe)
            wadj1b(ii, jj, irhoe) = tmp0b
            wadj1b(ii, jj, irho) = wadj1b(ii, jj, irho) - factk*wadj1(ii&
&              , jj, itu1)*tmp0b
            wadj1b(ii, jj, itu1) = wadj1b(ii, jj, itu1) - factk*wadj1(ii&
&              , jj, irho)*tmp0b
          END IF
          CALL POPREAL8(wadj1(ii, jj, irhoe))
          tmpb = wadj1b(ii, jj, irhoe)
          wadj1b(ii, jj, irhoe) = 0.0
          tempb3 = half*wadj1(ii, jj, irho)*tmpb
          padj1b(ii, jj) = padj1b(ii, jj) + ovgm1*tmpb
          wadj1b(ii, jj, irho) = wadj1b(ii, jj, irho) + cc*padj1b(ii, jj&
&            ) + half*(uf**2+vf**2+wf**2)*tmpb
          wfb = wadj1b(ii, jj, ivz) + 2*wf*tempb3
          wadj1b(ii, jj, ivz) = 0.0
          vfb = wadj1b(ii, jj, ivy) + 2*vf*tempb3
          wadj1b(ii, jj, ivy) = 0.0
          ufb = wadj1b(ii, jj, ivx) + 2*uf*tempb3
          wadj1b(ii, jj, ivx) = 0.0
          IF (wadj1b(ii, jj, irho) .EQ. 0.0 .OR. sf*cc .LE. 0.0 .AND. (&
&              ovgm1 .EQ. 0.0 .OR. ovgm1 .NE. INT(ovgm1))) THEN
            tempb4 = 0.0
          ELSE
            tempb4 = ovgm1*(sf*cc)**(ovgm1-1)*wadj1b(ii, jj, irho)
          END IF
          ccb = sf*tempb4 + wadj1(ii, jj, irho)*padj1b(ii, jj)
          padj1b(ii, jj) = 0.0
          CALL POPREAL8(wadj1(ii, jj, ivz))
          CALL POPREAL8(wadj1(ii, jj, ivy))
          CALL POPREAL8(wadj1(ii, jj, ivx))
          CALL POPREAL8(wadj1(ii, jj, irho))
          sfb = cc*tempb4
          wadj1b(ii, jj, irho) = 0.0
          CALL POPREAL8(cc)
          cfb = 2*cf*ccb/gammainf
          CALL POPINTEGER4(branch)
          IF (branch .LT. 1) THEN
            DO l=nt2mg,nt1mg,-1
              CALL POPREAL8(wadj1(ii, jj, l))
              wadj2b(ii, jj, l) = wadj2b(ii, jj, l) + wadj1b(ii, jj, l)
              wadj1b(ii, jj, l) = 0.0
            END DO
            CALL POPREAL8(sf)
            tempb2 = sfb/padj2(ii, jj)
            IF (.NOT.(tempb2 .EQ. 0.0 .OR. wadj2(ii, jj, irho) .LE. 0.0 &
&                .AND. (gammainf .EQ. 0.0 .OR. gammainf .NE. INT(&
&                gammainf)))) wadj2b(ii, jj, irho) = wadj2b(ii, jj, irho&
&                ) + gammainf*wadj2(ii, jj, irho)**(gammainf-1)*tempb2
            padj2b(ii, jj) = padj2b(ii, jj) - wadj2(ii, jj, irho)**&
&              gammainf*tempb2/padj2(ii, jj)
            CALL POPREAL8(wf)
            web = wfb
            qnfb = nnx*ufb + nny*vfb + nnz*wfb
            qneb = -(nnx*ufb) - nny*vfb - nnz*wfb
            nnzb = (qnf-qne)*wfb
            CALL POPREAL8(vf)
            veb = vfb
            nnyb = (qnf-qne)*vfb
            CALL POPREAL8(uf)
            ueb = ufb
            nnxb = (qnf-qne)*ufb
            qn0b = 0.0
          ELSE
            DO l=nt2mg,nt1mg,-1
              CALL POPREAL8(wadj1(ii, jj, l))
              winfadjb(l) = winfadjb(l) + wadj1b(ii, jj, l)
              wadj1b(ii, jj, l) = 0.0
            END DO
            CALL POPREAL8(sf)
            s0b = s0b + sfb
            CALL POPREAL8(wf)
            w0b = w0b + wfb
            qnfb = nnx*ufb + nny*vfb + nnz*wfb
            qn0b = -(nnx*ufb) - nny*vfb - nnz*wfb
            nnzb = (qnf-qn0)*wfb
            CALL POPREAL8(vf)
            v0b = v0b + vfb
            nnyb = (qnf-qn0)*vfb
            CALL POPREAL8(uf)
            u0b = u0b + ufb
            nnxb = (qnf-qn0)*ufb
            qneb = 0.0
            ueb = 0.0
            veb = 0.0
            web = 0.0
          END IF
          CALL POPREAL8(cf)
          tempb1 = fourth*gm1*cfb
          ac1b = half*qnfb + tempb1
          ac2b = half*qnfb - tempb1
          CALL POPREAL8(qnf)
          CALL POPINTEGER4(branch)
          IF (branch .LT. 1) THEN
            qneb = qneb + ac2b
            ceb = -(two*ovgm1*ac2b)
          ELSE
            qn0b = qn0b + ac2b
            c0b = c0b - two*ovgm1*ac2b
            ceb = 0.0
          END IF
          CALL POPINTEGER4(branch)
          IF (branch .LT. 1) THEN
            qneb = qneb + ac1b
            ceb = ceb + two*ovgm1*ac1b
          ELSE
            qn0b = qn0b + ac1b
            c0b = c0b + two*ovgm1*ac1b
          END IF
          tempb0 = gammainf*ceb/(2.0*SQRT(gammainf*(padj2(ii, jj)*re)))
          padj2b(ii, jj) = padj2b(ii, jj) + re*tempb0
          reb = padj2(ii, jj)*tempb0
          CALL POPREAL8(qne)
          ueb = ueb + nnx*qneb
          nnxb = nnxb + u0*qn0b + ue*qneb
          veb = veb + nny*qneb
          nnyb = nnyb + v0*qn0b + ve*qneb
          web = web + nnz*qneb
          nnzb = nnzb + w0*qn0b + we*qneb
          CALL POPREAL8(we)
          wadj2b(ii, jj, ivz) = wadj2b(ii, jj, ivz) + web
          CALL POPREAL8(ve)
          wadj2b(ii, jj, ivy) = wadj2b(ii, jj, ivy) + veb
          CALL POPREAL8(ue)
          wadj2b(ii, jj, ivx) = wadj2b(ii, jj, ivx) + ueb
          CALL POPREAL8(re)
          wadj2b(ii, jj, irho) = wadj2b(ii, jj, irho) - one*reb/wadj2(ii&
&            , jj, irho)**2
          CALL POPREAL8(qn0)
          u0b = u0b + nnx*qn0b
          v0b = v0b + nny*qn0b
          w0b = w0b + nnz*qn0b
          CALL POPREAL8(nnz)
          normadjb(nn, ii, jj, 3) = normadjb(nn, ii, jj, 3) + nnzb
          CALL POPREAL8(nny)
          normadjb(nn, ii, jj, 2) = normadjb(nn, ii, jj, 2) + nnyb
          CALL POPREAL8(nnx)
          normadjb(nn, ii, jj, 1) = normadjb(nn, ii, jj, 1) + nnxb
          CALL POPINTEGER4(jj)
          CALL POPINTEGER4(ii)
        END DO
      END DO
      CALL POPREAL8ARRAY(wadj1, 5**2*nw)
      CALL POPREAL8ARRAY(wadj2, 5**2*nw)
      CALL POPREAL8ARRAY(padj1, 5**2)
      CALL POPREAL8ARRAY(padj2, 5**2)
      CALL POPINTEGER4(ioffset)
      CALL POPINTEGER4(joffset)
      CALL POPINTEGER4(icbeg)
      CALL POPINTEGER4(jcbeg)
      CALL POPINTEGER4(icend)
      CALL POPINTEGER4(jcend)
      CALL POPBOOLEAN(secondhalo)
      padj3b(:, :) = 0.0
      wadj3b(:, :, :) = 0.0
      CALL EXTRACTBCSTATESADJ_B(nn, wadj, wadjb, padj, padjb, wadj0, &
&                          wadj0b, wadj1, wadj1b, wadj2, wadj2b, wadj3, &
&                          wadj3b, padj0, padj0b, padj1, padj1b, padj2, &
&                          padj2b, padj3, padj3b, rlvadj, revadj, &
&                          rlvadj1, rlvadj2, revadj1, revadj2, ioffset, &
&                          joffset, koffset, icell, jcell, kcell, isbeg&
&                          , jsbeg, ksbeg, isend, jsend, ksend, ibbeg, &
&                          jbbeg, kbbeg, ibend, jbend, kbend, icbeg, &
&                          jcbeg, icend, jcend, secondhalo)
    END IF
    CALL POPINTEGER4(isbeg)
    CALL POPINTEGER4(jsbeg)
    CALL POPINTEGER4(ksbeg)
    CALL POPINTEGER4(isend)
    CALL POPINTEGER4(jsend)
    CALL POPINTEGER4(ksend)
    CALL POPINTEGER4(ibbeg)
    CALL POPINTEGER4(jbbeg)
    CALL POPINTEGER4(kbbeg)
    CALL POPINTEGER4(ibend)
    CALL POPINTEGER4(jbend)
    CALL POPINTEGER4(kbend)
  END DO
  IF (.NOT.(s0b .EQ. 0.0 .OR. winfadj(irho) .LE. 0.0 .AND. (gammainf &
&      .EQ. 0.0 .OR. gammainf .NE. INT(gammainf)))) winfadjb(irho) = &
&      winfadjb(irho) + gammainf*winfadj(irho)**(gammainf-1)*s0b/&
&      pinfcorradj
  tempb = gammainf*c0b/(2.0*SQRT(gammainf*(pinfcorradj*r0)))
  pinfcorradjb = pinfcorradjb + r0*tempb - winfadj(irho)**gammainf*s0b/&
&    pinfcorradj**2
  r0b = pinfcorradj*tempb
  winfadjb(ivz) = winfadjb(ivz) + w0b
  winfadjb(ivy) = winfadjb(ivy) + v0b
  winfadjb(ivx) = winfadjb(ivx) + u0b
  winfadjb(irho) = winfadjb(irho) - one*r0b/winfadj(irho)**2
END SUBROUTINE BCFARFIELDADJ_B

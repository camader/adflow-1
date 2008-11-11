!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
!  
!  Differentiation of replacebcstatesadj in reverse (adjoint) mode:
!   gradient, with respect to input variables: padj0 padj1 padj
!                wadj wadj0 wadj1
!   of linear combination of output variables: padj0 padj1 padj
!                wadj wadj0 wadj1
!
!      ******************************************************************
!      *                                                                *
!      * File:          replaceBCStatesAdj.f90                          *
!      * Author:        C.A.(Sandy) Mader                               *
!      * Starting date: 04-17-2008                                      *
!      * Last modified: 04-17-2008                                      *
!      *                                                                *
!      ******************************************************************
!
SUBROUTINE REPLACEBCSTATESADJ_B(nn, wadj0, wadj0b, wadj1, wadj1b, wadj2&
&  , wadj3, padj0, padj0b, padj1, padj1b, padj2, padj3, rlvadj1, rlvadj2&
&  , revadj1, revadj2, icell, jcell, kcell, wadj, wadjb, padj, padjb, &
&  rlvadj, revadj, secondhalo)
  USE bctypes
  USE blockpointers, ONLY : ie, ib, je, jb, ke, kb, nbocos, bcfaceid, &
&  bctype, bcdata
  USE flowvarrefstate
  IMPLICIT NONE
  INTEGER(KIND=INTTYPE) :: icell, jcell, kcell
  INTEGER(KIND=INTTYPE), INTENT(IN) :: nn
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2), INTENT(IN) :: padj0
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2), INTENT(IN) :: padj1
  REAL(KIND=REALTYPE) :: padj0b(-2:2, -2:2), padj1b(-2:2, -2:2)
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2), INTENT(IN) :: padj2
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2), INTENT(IN) :: padj3
  REAL(KIND=REALTYPE) :: padj(-2:2, -2:2, -2:2), padjb(-2:2, -2:2, -2:2)
  REAL(KIND=REALTYPE) :: revadj1(-2:2, -2:2), revadj2(-2:2, -2:2)
  REAL(KIND=REALTYPE) :: revadj(-2:2, -2:2, -2:2), rlvadj(-2:2, -2:2, -2&
&  :2)
  REAL(KIND=REALTYPE) :: rlvadj1(-2:2, -2:2), rlvadj2(-2:2, -2:2)
  LOGICAL :: secondhalo
  REAL(KIND=REALTYPE) :: wadj(-2:2, -2:2, -2:2, nw), wadjb(-2:2, -2:2, -&
&  2:2, nw)
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, nw), INTENT(IN) :: wadj0
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, nw), INTENT(IN) :: wadj1
  REAL(KIND=REALTYPE) :: wadj0b(-2:2, -2:2, nw), wadj1b(-2:2, -2:2, nw)
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, nw), INTENT(IN) :: wadj2
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, nw), INTENT(IN) :: wadj3
  INTEGER(KIND=INTTYPE) :: i, j, k, l
!      modules
! Copy the information back to the original arrays wAdj and pAdj.
  SELECT CASE  (bcfaceid(nn)) 
  CASE (imin) 
    IF (secondhalo) THEN
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-1, -2:2, -2:2)
      padjb(-1, -2:2, -2:2) = 0.0
      padj0b(-2:2, -2:2) = padj0b(-2:2, -2:2) + padjb(-2, -2:2, -2:2)
      padjb(-2, -2:2, -2:2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-1, -2&
&        :2, -2:2, 1:nw)
      wadjb(-1, -2:2, -2:2, 1:nw) = 0.0
      wadj0b(-2:2, -2:2, 1:nw) = wadj0b(-2:2, -2:2, 1:nw) + wadjb(-2, -2&
&        :2, -2:2, 1:nw)
      wadjb(-2, -2:2, -2:2, 1:nw) = 0.0
    ELSE
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-2, -2:2, -2:2)
      padjb(-2, -2:2, -2:2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-2, -2&
&        :2, -2:2, 1:nw)
      wadjb(-2, -2:2, -2:2, 1:nw) = 0.0
    END IF
  CASE (imax) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(1, -2:2, -2:2)
      padjb(1, -2:2, -2:2) = 0.0
      padj0b(-2:2, -2:2) = padj0b(-2:2, -2:2) + padjb(2, -2:2, -2:2)
      padjb(2, -2:2, -2:2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(1, -2:&
&        2, -2:2, 1:nw)
      wadjb(1, -2:2, -2:2, 1:nw) = 0.0
      wadj0b(-2:2, -2:2, 1:nw) = wadj0b(-2:2, -2:2, 1:nw) + wadjb(2, -2:&
&        2, -2:2, 1:nw)
      wadjb(2, -2:2, -2:2, 1:nw) = 0.0
    ELSE
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(2, -2:2, -2:2)
      padjb(2, -2:2, -2:2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(2, -2:&
&        2, -2:2, 1:nw)
      wadjb(2, -2:2, -2:2, 1:nw) = 0.0
    END IF
  CASE (jmin) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-2:2, -1, -2:2)
      padjb(-2:2, -1, -2:2) = 0.0
      padj0b(-2:2, -2:2) = padj0b(-2:2, -2:2) + padjb(-2:2, -2, -2:2)
      padjb(-2:2, -2, -2:2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        -1, -2:2, 1:nw)
      wadjb(-2:2, -1, -2:2, 1:nw) = 0.0
      wadj0b(-2:2, -2:2, 1:nw) = wadj0b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        -2, -2:2, 1:nw)
      wadjb(-2:2, -2, -2:2, 1:nw) = 0.0
    ELSE
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-2:2, -2, -2:2)
      padjb(-2:2, -2, -2:2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        -2, -2:2, 1:nw)
      wadjb(-2:2, -2, -2:2, 1:nw) = 0.0
    END IF
  CASE (jmax) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-2:2, 1, -2:2)
      padjb(-2:2, 1, -2:2) = 0.0
      padj0b(-2:2, -2:2) = padj0b(-2:2, -2:2) + padjb(-2:2, 2, -2:2)
      padjb(-2:2, 2, -2:2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        1, -2:2, 1:nw)
      wadjb(-2:2, 1, -2:2, 1:nw) = 0.0
      wadj0b(-2:2, -2:2, 1:nw) = wadj0b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        2, -2:2, 1:nw)
      wadjb(-2:2, 2, -2:2, 1:nw) = 0.0
    ELSE
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-2:2, 2, -2:2)
      padjb(-2:2, 2, -2:2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        2, -2:2, 1:nw)
      wadjb(-2:2, 2, -2:2, 1:nw) = 0.0
    END IF
  CASE (kmin) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-2:2, -2:2, -1)
      padjb(-2:2, -2:2, -1) = 0.0
      padj0b(-2:2, -2:2) = padj0b(-2:2, -2:2) + padjb(-2:2, -2:2, -2)
      padjb(-2:2, -2:2, -2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        -2:2, -1, 1:nw)
      wadjb(-2:2, -2:2, -1, 1:nw) = 0.0
      wadj0b(-2:2, -2:2, 1:nw) = wadj0b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        -2:2, -2, 1:nw)
      wadjb(-2:2, -2:2, -2, 1:nw) = 0.0
    ELSE
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-2:2, -2:2, -2)
      padjb(-2:2, -2:2, -2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        -2:2, -2, 1:nw)
      wadjb(-2:2, -2:2, -2, 1:nw) = 0.0
    END IF
  CASE (kmax) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-2:2, -2:2, 1)
      padjb(-2:2, -2:2, 1) = 0.0
      padj0b(-2:2, -2:2) = padj0b(-2:2, -2:2) + padjb(-2:2, -2:2, 2)
      padjb(-2:2, -2:2, 2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        -2:2, 1, 1:nw)
      wadjb(-2:2, -2:2, 1, 1:nw) = 0.0
      wadj0b(-2:2, -2:2, 1:nw) = wadj0b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        -2:2, 2, 1:nw)
      wadjb(-2:2, -2:2, 2, 1:nw) = 0.0
    ELSE
      padj1b(-2:2, -2:2) = padj1b(-2:2, -2:2) + padjb(-2:2, -2:2, 2)
      padjb(-2:2, -2:2, 2) = 0.0
      wadj1b(-2:2, -2:2, 1:nw) = wadj1b(-2:2, -2:2, 1:nw) + wadjb(-2:2, &
&        -2:2, 2, 1:nw)
      wadjb(-2:2, -2:2, 2, 1:nw) = 0.0
    END IF
  END SELECT
END SUBROUTINE REPLACEBCSTATESADJ_B

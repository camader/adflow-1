   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of getdirangle in forward (tangent) mode (with options i4 dr8 r8):
   !   variations   of useful results: alpha beta
   !   with respect to varying inputs: freestreamaxis
   !
   !     ******************************************************************
   !     *                                                                *
   !     * File:          getDirAngle.f90                                 *
   !     * Author:        Andre C. Marta,C.A.(Sandy) Mader                *
   !     * Starting date: 10-25-2005                                      *
   !     * Last modified: 06-13-2008                                      *
   !     *                                                                *
   !     ******************************************************************
   !
   SUBROUTINE GETDIRANGLE_D(freestreamaxis, freestreamaxisd, liftaxis, &
   & liftindex, alpha, alphad, beta, betad)
   !
   !     ******************************************************************
   !     *                                                                *
   !     * Convert the wind axes to angle of attack and side slip angle.  *
   !     * The direction angles alpha and beta are computed given the     *
   !     * components of the wind direction vector (freeStreamAxis), the  *
   !     * lift direction vector (liftAxis) and assuming that the         *
   !     * body direction (xb,yb,zb) is in the default ijk coordinate     *
   !     * system. The rotations are determined by first determining      *
   !     * whether the lift is primarily in the j or k direction and then *
   !     * determining the angles accordingly.                            *
   !     * direction vector:                                              *
   !     *   1) Rotation about the zb or yb -axis: alpha clockwise (CW)   *
   !     *      (xb,yb,zb) -> (x1,y1,z1)                                  *
   !     *                                                                *
   !     *   2) Rotation about the yl or z1 -axis: beta counter-clockwise *
   !     *      (CCW) (x1,y1,z1) -> (xw,yw,zw)                            *
   !     *                                                                *
   !     *    input arguments:                                            *
   !     *       freeStreamAxis = wind vector in body axes                *
   !     *       liftAxis       = lift direction vector in body axis      *       
   !     *    output arguments:                                           *
   !     *       alpha    = angle of attack in radians                    *
   !     *       beta     = side slip angle in radians                    *
   !     *                                                                *
   !     ******************************************************************
   !
   USE CONSTANTS
   IMPLICIT NONE
   !
   !     Subroutine arguments.
   !
   !      real(kind=realType), intent(in)  :: xw, yw, zw
   REAL(kind=realtype), DIMENSION(3), INTENT(IN) :: freestreamaxis
   REAL(kind=realtype), DIMENSION(3), INTENT(IN) :: freestreamaxisd
   REAL(kind=realtype), DIMENSION(3), INTENT(IN) :: liftaxis
   REAL(kind=realtype), INTENT(OUT) :: alpha, beta
   REAL(kind=realtype), INTENT(OUT) :: alphad, betad
   INTEGER(kind=inttype), INTENT(OUT) :: liftindex
   !
   !     Local variables.
   !
   REAL(kind=realtype) :: rnorm
   REAL(kind=realtype) :: rnormd
   INTEGER(kind=inttype) :: flowindex, i
   REAL(kind=realtype), DIMENSION(3) :: freestreamaxisnorm
   REAL(kind=realtype), DIMENSION(3) :: freestreamaxisnormd
   INTEGER(kind=inttype) :: temp
   INTRINSIC ABS
   INTRINSIC SQRT
   INTRINSIC ASIN
   INTRINSIC ATAN2
   REAL(kind=realtype) :: arg1
   REAL(kind=realtype) :: arg1d
   REAL(kind=realtype) :: abs7
   REAL(kind=realtype) :: abs6
   REAL(kind=realtype) :: abs5
   REAL(kind=realtype) :: abs4
   REAL(kind=realtype) :: abs3
   REAL(kind=realtype) :: abs2
   REAL(kind=realtype) :: abs1
   REAL(kind=realtype) :: abs0
   !
   !     ******************************************************************
   !     *                                                                *
   !     * Begin execution.                                               *
   !     *                                                                *
   !     ******************************************************************
   !
   ! Assume domoniate flow is x
   flowindex = 1
   IF (liftaxis(1) .GE. 0.) THEN
   abs0 = liftaxis(1)
   ELSE
   abs0 = -liftaxis(1)
   END IF
   IF (liftaxis(2) .GE. 0.) THEN
   abs2 = liftaxis(2)
   ELSE
   abs2 = -liftaxis(2)
   END IF
   IF (liftaxis(1) .GE. 0.) THEN
   abs4 = liftaxis(1)
   ELSE
   abs4 = -liftaxis(1)
   END IF
   IF (liftaxis(3) .GE. 0.) THEN
   abs6 = liftaxis(3)
   ELSE
   abs6 = -liftaxis(3)
   END IF
   ! Determine the dominant lift direction
   IF (abs0 .GT. abs2 .AND. abs4 .GT. abs6) THEN
   temp = 1
   ELSE
   IF (liftaxis(2) .GE. 0.) THEN
   abs1 = liftaxis(2)
   ELSE
   abs1 = -liftaxis(2)
   END IF
   IF (liftaxis(1) .GE. 0.) THEN
   abs3 = liftaxis(1)
   ELSE
   abs3 = -liftaxis(1)
   END IF
   IF (liftaxis(2) .GE. 0.) THEN
   abs5 = liftaxis(2)
   ELSE
   abs5 = -liftaxis(2)
   END IF
   IF (liftaxis(3) .GE. 0.) THEN
   abs7 = liftaxis(3)
   ELSE
   abs7 = -liftaxis(3)
   END IF
   IF (abs1 .GT. abs3 .AND. abs5 .GT. abs7) THEN
   temp = 2
   ELSE
   temp = 3
   END IF
   END IF
   liftindex = temp
   ! Normalize the freeStreamDirection vector.
   arg1d = 2*freestreamaxis(1)*freestreamaxisd(1) + 2*freestreamaxis(2)*&
   &   freestreamaxisd(2) + 2*freestreamaxis(3)*freestreamaxisd(3)
   arg1 = freestreamaxis(1)**2 + freestreamaxis(2)**2 + freestreamaxis(3)&
   &   **2
   IF (arg1 .EQ. 0.0_8) THEN
   rnormd = 0.0_8
   ELSE
   rnormd = arg1d/(2.0*SQRT(arg1))
   END IF
   rnorm = SQRT(arg1)
   freestreamaxisnormd = 0.0_8
   DO i=1,3
   freestreamaxisnormd(i) = (freestreamaxisd(i)*rnorm-freestreamaxis(i)&
   &     *rnormd)/rnorm**2
   freestreamaxisnorm(i) = freestreamaxis(i)/rnorm
   END DO
   IF (liftindex .EQ. 2) THEN
   ! different coordinate system for aerosurf
   ! Wing is in z- direction
   ! Compute angle of attack alpha.
   IF (freestreamaxisnorm(2) .EQ. 1.0 .OR. freestreamaxisnorm(2) .EQ. (&
   &       -1.0)) THEN
   alphad = 0.0_8
   ELSE
   alphad = freestreamaxisnormd(2)/SQRT(1.0-freestreamaxisnorm(2)**2)
   END IF
   alpha = ASIN(freestreamaxisnorm(2))
   ! Compute side-slip angle beta.
   betad = -((freestreamaxisnormd(3)*freestreamaxisnorm(1)-&
   &     freestreamaxisnormd(1)*freestreamaxisnorm(3))/(freestreamaxisnorm(&
   &     3)**2+freestreamaxisnorm(1)**2))
   beta = -ATAN2(freestreamaxisnorm(3), freestreamaxisnorm(1))
   ELSE IF (liftindex .EQ. 3) THEN
   ! Wing is in y- direction
   ! Compute angle of attack alpha.
   IF (freestreamaxisnorm(3) .EQ. 1.0 .OR. freestreamaxisnorm(3) .EQ. (&
   &       -1.0)) THEN
   alphad = 0.0_8
   ELSE
   alphad = freestreamaxisnormd(3)/SQRT(1.0-freestreamaxisnorm(3)**2)
   END IF
   alpha = ASIN(freestreamaxisnorm(3))
   ! Compute side-slip angle beta.
   betad = (freestreamaxisnormd(2)*freestreamaxisnorm(1)-&
   &     freestreamaxisnormd(1)*freestreamaxisnorm(2))/(freestreamaxisnorm(&
   &     2)**2+freestreamaxisnorm(1)**2)
   beta = ATAN2(freestreamaxisnorm(2), freestreamaxisnorm(1))
   ELSE
   CALL TERMINATE('getDirAngle', 'Invalid Lift Direction')
   alphad = 0.0_8
   betad = 0.0_8
   END IF
   END SUBROUTINE GETDIRANGLE_D

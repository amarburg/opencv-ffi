
#include <opencv2/core/types_c.h>

#include <stdio.h>

typedef struct {
  CvPoint2D32f train, query;
  double distance;
} Match_t;

typedef struct {
  int length;
  Match_t *d;
  double *error;
} MatchSet_t;

extern "C"
double computeReprojError( const Match_t *match, const CvMat *model )
{
  const double* F = model->data.db;
   const CvPoint2D32f *m1 = &(match->train);
   const CvPoint2D32f *m2 = &(match->query);

     double a, b, c, d1, d2, s1, s2;

     a = F[0]*m1->x + F[1]*m1->y + F[2];
     b = F[3]*m1->x + F[4]*m1->y + F[5];
     c = F[6]*m1->x + F[7]*m1->y + F[8];

     s2 = 1./(a*a + b*b);
     d2 = m2->x*a + m2->y*b + c;

     a = F[0]*m2->x + F[3]*m2->y + F[6];
     b = F[1]*m2->x + F[4]*m2->y + F[7];
     c = F[2]*m2->x + F[5]*m2->y + F[8];

     s1 = 1./(a*a + b*b);
     d1 = m1->x*a + m1->y*b + c;


     a = d1*d1*s1;
     b = d2*d2*s2;

     if( a>b )
       return a;
     else
       return b;
}

extern "C"
void computeSetReprojError( MatchSet_t *set, CvMat *model )
{
  //for( int i = 0; i < set->length; i ++ ) {
  for( int i = 0; i < 5; i ++ ) {
    set->error[i] = computeReprojError( &(set->d[i]), model );
  }
}

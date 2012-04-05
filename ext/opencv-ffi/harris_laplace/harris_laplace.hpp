 
#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "gaussian_pyramid.hpp"
 
#ifdef __cplusplus
#include <limits>

namespace cv {
 
/*
 * Elliptic region around interest point 
 */
class CV_EXPORTS Elliptic_KeyPoint : public KeyPoint {
public:
	Point centre;
	Size_<float> axes;
	double phi;
	float size;
	float si;
	Mat transf;
	Elliptic_KeyPoint();
	Elliptic_KeyPoint(Point centre, double phi, Size axes, float size, float si);
	virtual ~Elliptic_KeyPoint();
};

class CV_EXPORTS HarrisLaplace
{

public:
    HarrisLaplace();
    HarrisLaplace(int numOctaves, float corn_thresh, float DOG_thresh,int maxCorners=1500, int num_layers=4);
    void detect(const Mat& image, vector<KeyPoint>& keypoints) const;
    virtual ~HarrisLaplace();

    int numOctaves;
    float corn_thresh;
    float DOG_thresh;
    int maxCorners;
    int num_layers;

};
 
class CV_EXPORTS HarrisLaplaceFeatureDetector : public FeatureDetector
{
public:
 class CV_EXPORTS Params
    {
    public:
        Params( int numOctaves=6, float corn_thresh=0.01, float DOG_thresh=0.01, int maxCorners=5000, int num_layers=4 );
        

        int numOctaves;
        float corn_thresh;
        float DOG_thresh;
        int maxCorners;
        int num_layers;
       
    };
    HarrisLaplaceFeatureDetector( const HarrisLaplaceFeatureDetector::Params& params=HarrisLaplaceFeatureDetector::Params() );
    HarrisLaplaceFeatureDetector( int numOctaves, float corn_thresh, float DOG_thresh, int maxCorners, int num_layers);
    virtual void read( const FileNode& fn );
    virtual void write( FileStorage& fs ) const;

protected:
	virtual void detectImpl( const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask=Mat() ) const;

    HarrisLaplace harris;
    Params params;
};


class CV_EXPORTS HarrisAffineFeatureDetector : public FeatureDetector
{
public:
 class CV_EXPORTS Params
    {
    public:
        Params( int numOctaves=6, float corn_thresh=0.01, float DOG_thresh=0.01, int maxCorners=5000, int num_layers=4 );
        

        int numOctaves;
        float corn_thresh;
        float DOG_thresh;
        int maxCorners;
        int num_layers;
       
    };
    HarrisAffineFeatureDetector( const HarrisAffineFeatureDetector::Params& params=HarrisAffineFeatureDetector::Params() );
    HarrisAffineFeatureDetector( int numOctaves, float corn_thresh, float DOG_thresh, int maxCorners, int num_layers);
    void detect( const Mat& image, vector<Elliptic_KeyPoint>& keypoints, const Mat& mask=Mat() ) const;
    virtual void read( const FileNode& fn );
    virtual void write( FileStorage& fs ) const;

protected:
	virtual void detectImpl( const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask=Mat() ) const;

    HarrisLaplace harris;
    Params params;
};

CV_EXPORTS void evaluateFeatureDetector( const Mat& img1, const Mat& img2, const Mat& H1to2,
                              vector<Elliptic_KeyPoint>* _keypoints1, vector<Elliptic_KeyPoint>* _keypoints2,
                              float& repeatability, int& correspCount,
                              const Ptr<HarrisAffineFeatureDetector>& _fdetector );
 CV_EXPORTS void computeRecallPrecisionCurve( const vector<vector<DMatch> >& matches1to2,
                                              const vector<vector<uchar> >& correctMatches1to2Mask,
                                              vector<Point2f>& recallPrecisionCurve );
 
/*
 * Functions to perform affine adaptation of circular keypoint 
 */
void calcAffineCovariantRegions(const Mat& image, const vector<KeyPoint>& keypoints, vector<Elliptic_KeyPoint>& affRegions, string detector_type);
void calcAffineCovariantDescriptors( const Ptr<DescriptorExtractor>& dextractor, const Mat& img, vector<Elliptic_KeyPoint>& affRegions, Mat& descriptors );

} /* namespace cv */
 
extern "C" {
#endif /* __cplusplus */

  typedef struct CvEllipticKeyPoint {
    CvPoint centre;
    CvSize axes;
    double phi;
    float size, si;
    CvMat transf;
  } CvEllipticKeyPoint_t;

  // How's the DRY now?
  typedef struct CvHarrisLaplaceParams {
    int numOctaves;
    float corn_thresh;
    float DOG_thresh;
    int maxCorners;
    int num_layers;
  } CvHarrisLaplaceParams;

  typedef struct CvHarrisAffineParams {
    int numOctaves;
    float corn_thresh;
    float DOG_thresh;
    int maxCorners;
    int num_layers;
  } CvHarrisAffineParams;

  CvSeq *cvHarrisLaplaceDetector( const CvArr *image, CvMemStorage *storage, CvHarrisLaplaceParams params );
  CvSeq *cvHarrisAffineDetector( const CvArr *image, CvMemStorage *storage, CvHarrisAffineParams params );

#ifdef __cplusplus
}
#endif


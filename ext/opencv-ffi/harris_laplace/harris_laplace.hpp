Index: include/opencv2/features2d/features2d.hpp
===================================================================
--- include/opencv2/features2d/features2d.hpp	(revisione 5053)
+++ include/opencv2/features2d/features2d.hpp	(copia locale)
@@ -45,6 +45,7 @@
 
 #include "opencv2/core/core.hpp"
 #include "opencv2/flann/flann.hpp"
+#include "opencv2/imgproc/gaussian_pyramid.hpp"
 
 #ifdef __cplusplus
 #include <limits>
@@ -264,6 +265,23 @@
 CV_EXPORTS void read(const FileNode& node, CV_OUT vector<KeyPoint>& keypoints);    
 
 /*
+ * Elliptic region around interest point 
+ */
+class CV_EXPORTS Elliptic_KeyPoint : public KeyPoint{
+public:
+	Point centre;
+	Size_<float> axes;
+	double phi;
+	float size;
+	float si;
+	Mat transf;
+	Elliptic_KeyPoint();
+	Elliptic_KeyPoint(Point centre, double phi, Size axes, float size, float si);
+	virtual ~Elliptic_KeyPoint();
+};
+
+
+/*
  * A class filters a vector of keypoints.
  * Because now it is difficult to provide a convenient interface for all usage scenarios of the keypoints filter class,
  * it has only 3 needed by now static methods.
@@ -422,6 +440,24 @@
         CV_OUT vector<vector<Point> >& msers, const Mat& mask ) const;
 };
 
+class CV_EXPORTS HarrisLaplace
+{
+
+public:
+    HarrisLaplace();
+    HarrisLaplace(int numOctaves, float corn_thresh, float DOG_thresh,int maxCorners=1500, int num_layers=4);
+    void detect(const Mat& image, vector<KeyPoint>& keypoints) const;
+    virtual ~HarrisLaplace();
+
+    int numOctaves;
+    float corn_thresh;
+    float DOG_thresh;
+    int maxCorners;
+    int num_layers;
+
+};
+
+
 /*!
  The "Star" Detector.
  
@@ -1478,6 +1514,64 @@
     int levels;
 };
 
+class CV_EXPORTS HarrisLaplaceFeatureDetector : public FeatureDetector
+{
+public:
+ class CV_EXPORTS Params
+    {
+    public:
+        Params( int numOctaves=6, float corn_thresh=0.01, float DOG_thresh=0.01, int maxCorners=5000, int num_layers=4 );
+        
+
+        int numOctaves;
+        float corn_thresh;
+        float DOG_thresh;
+        int maxCorners;
+        int num_layers;
+       
+    };
+    HarrisLaplaceFeatureDetector( const HarrisLaplaceFeatureDetector::Params& params=HarrisLaplaceFeatureDetector::Params() );
+    HarrisLaplaceFeatureDetector( int numOctaves, float corn_thresh, float DOG_thresh, int maxCorners, int num_layers);
+    virtual void read( const FileNode& fn );
+    virtual void write( FileStorage& fs ) const;
+
+protected:
+	virtual void detectImpl( const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask=Mat() ) const;
+
+    HarrisLaplace harris;
+    Params params;
+};
+
+
+class CV_EXPORTS HarrisAffineFeatureDetector : public FeatureDetector
+{
+public:
+ class CV_EXPORTS Params
+    {
+    public:
+        Params( int numOctaves=6, float corn_thresh=0.01, float DOG_thresh=0.01, int maxCorners=5000, int num_layers=4 );
+        
+
+        int numOctaves;
+        float corn_thresh;
+        float DOG_thresh;
+        int maxCorners;
+        int num_layers;
+       
+    };
+    HarrisAffineFeatureDetector( const HarrisAffineFeatureDetector::Params& params=HarrisAffineFeatureDetector::Params() );
+    HarrisAffineFeatureDetector( int numOctaves, float corn_thresh, float DOG_thresh, int maxCorners, int num_layers);
+    void detect( const Mat& image, vector<Elliptic_KeyPoint>& keypoints, const Mat& mask=Mat() ) const;
+    virtual void read( const FileNode& fn );
+    virtual void write( FileStorage& fs ) const;
+
+protected:
+	virtual void detectImpl( const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask=Mat() ) const;
+
+    HarrisLaplace harris;
+    Params params;
+};
+
 /** \brief A feature detector parameter adjuster, this is used by the DynamicAdaptedFeatureDetector
  *  and is a wrapper for FeatureDetector that allow them to be adjusted after a detection
  */
@@ -2688,6 +2782,10 @@
                                          float& repeatability, int& correspCount,
                                          const Ptr<FeatureDetector>& fdetector=Ptr<FeatureDetector>() );
 
+CV_EXPORTS void evaluateFeatureDetector( const Mat& img1, const Mat& img2, const Mat& H1to2,
+                              vector<Elliptic_KeyPoint>* _keypoints1, vector<Elliptic_KeyPoint>* _keypoints2,
+                              float& repeatability, int& correspCount,
+                              const Ptr<HarrisAffineFeatureDetector>& _fdetector );
 CV_EXPORTS void computeRecallPrecisionCurve( const vector<vector<DMatch> >& matches1to2,
                                              const vector<vector<uchar> >& correctMatches1to2Mask,
                                              vector<Point2f>& recallPrecisionCurve );
@@ -2780,6 +2878,11 @@
     Ptr<DescriptorMatcher> dmatcher;
 };
 
+/*
+ * Functions to perform affine adaptation of circular keypoint 
+ */
+void calcAffineCovariantRegions(const Mat& image, const vector<KeyPoint>& keypoints, vector<Elliptic_KeyPoint>& affRegions, string detector_type);
+void calcAffineCovariantDescriptors( const Ptr<DescriptorExtractor>& dextractor, const Mat& img, vector<Elliptic_KeyPoint>& affRegions, Mat& descriptors );
 } /* namespace cv */
 
 #endif /* __cplusplus */


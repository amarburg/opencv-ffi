Index: src/detectors.cpp
===================================================================
--- src/detectors.cpp	(revisione 5053)
+++ src/detectors.cpp	(copia locale)
@@ -132,6 +132,14 @@
         pos += string("Dynamic").size();
         fd = new DynamicAdaptedFeatureDetector( AdjusterAdapter::create(detectorType.substr(pos)) );
     }
+    else if( !detectorType.compare( "HarrisLaplace" ) )
+    {
+        fd = new HarrisLaplaceFeatureDetector();
+    }
+    else if( !detectorType.compare( "HarrisAffine" ) )
+    {
+        fd = new HarrisAffineFeatureDetector();
+    }
 
     return fd;
 }
@@ -567,4 +575,98 @@
     }
 }
 
+/*
+ *  HarrisLaplaceFeatureDetector
+ */
+HarrisLaplaceFeatureDetector::Params::Params(int _numOctaves, float _corn_thresh, float _DOG_thresh, int _maxCorners, int _num_layers) :
+    numOctaves(_numOctaves), corn_thresh(_corn_thresh), DOG_thresh(_DOG_thresh), maxCorners(_maxCorners), num_layers(_num_layers)
+{}
+HarrisLaplaceFeatureDetector::HarrisLaplaceFeatureDetector( int numOctaves, float corn_thresh, float DOG_thresh, int maxCorners, int num_layers)
+  : harris( numOctaves, corn_thresh, DOG_thresh, maxCorners, num_layers)
+{}
+
+HarrisLaplaceFeatureDetector::HarrisLaplaceFeatureDetector(  const Params& params  )
+ : harris( params.numOctaves, params.corn_thresh, params.DOG_thresh, params.maxCorners, params.num_layers)
+ 
+{}
+
+void HarrisLaplaceFeatureDetector::read (const FileNode& fn)
+{
+	int numOctaves = fn["numOctaves"];
+	float corn_thresh = fn["corn_thresh"];
+	float DOG_thresh = fn["DOG_thresh"];
+	int maxCorners = fn["maxCorners"];
+	int num_layers = fn["num_layers"];
+	
+    harris = HarrisLaplace( numOctaves, corn_thresh, DOG_thresh, maxCorners,num_layers );
 }
+
+void HarrisLaplaceFeatureDetector::write (FileStorage& fs) const
+{
+
+    fs << "numOctaves" << harris.numOctaves;
+    fs << "corn_thresh" << harris.corn_thresh;
+    fs << "DOG_thresh" << harris.DOG_thresh;
+    fs << "maxCorners" << harris.maxCorners;
+    fs << "num_layers" << harris.num_layers;
+
+    
+}
+
+
+void HarrisLaplaceFeatureDetector::detectImpl( const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask ) const
+{
+	       
+	harris.detect(image, keypoints);
+}
+
+/*
+ *  HarrisAffineFeatureDetector
+ */
+HarrisAffineFeatureDetector::Params::Params(int _numOctaves, float _corn_thresh, float _DOG_thresh, int _maxCorners, int _num_layers) :
+    numOctaves(_numOctaves), corn_thresh(_corn_thresh), DOG_thresh(_DOG_thresh), maxCorners(_maxCorners), num_layers(_num_layers)
+{}
+HarrisAffineFeatureDetector::HarrisAffineFeatureDetector( int numOctaves, float corn_thresh, float DOG_thresh, int maxCorners, int num_layers)
+  : harris( numOctaves, corn_thresh, DOG_thresh, maxCorners, num_layers)
+{}
+
+HarrisAffineFeatureDetector::HarrisAffineFeatureDetector(  const Params& params  )
+ : harris( params.numOctaves, params.corn_thresh, params.DOG_thresh, params.maxCorners, params.num_layers)
+ 
+{}
+
+void HarrisAffineFeatureDetector::read (const FileNode& fn)
+{
+	int numOctaves = fn["numOctaves"];
+	float corn_thresh = fn["corn_thresh"];
+	float DOG_thresh = fn["DOG_thresh"];
+	int maxCorners = fn["maxCorners"];
+	int num_layers = fn["num_layers"];
+	
+    harris = HarrisLaplace( numOctaves, corn_thresh, DOG_thresh, maxCorners,num_layers );
+}
+
+void HarrisAffineFeatureDetector::write (FileStorage& fs) const
+{
+
+    fs << "numOctaves" << harris.numOctaves;
+    fs << "corn_thresh" << harris.corn_thresh;
+    fs << "DOG_thresh" << harris.DOG_thresh;
+    fs << "maxCorners" << harris.maxCorners;
+    fs << "num_layers" << harris.num_layers;
+
+    
+}
+void HarrisAffineFeatureDetector::detect( const Mat& image, vector<Elliptic_KeyPoint>& ekeypoints, const Mat& mask ) const
+{
+	vector<KeyPoint> keypoints;
+	harris.detect(image, keypoints);
+	Mat fimage;
+    image.convertTo(fimage, CV_32F, 1.f/255);
+	calcAffineCovariantRegions(fimage, keypoints, ekeypoints, "HarrisLaplace");
+	}
+
+void HarrisAffineFeatureDetector::detectImpl( const Mat& image, vector<KeyPoint>& ekeypoints, const Mat& mask ) const
+{
+}
+}
I
//
// Taken from Delia Passalacqua's HarrisLaplace.patch
//  http://code.opencv.org/attachments/609/HarrisLaplace.patch
//
#include "precomp.hpp"
#include <opencv2/imgproc/gaussian_pyramid.hpp>

namespace cv
{
bool sort_func(KeyPoint kp1, KeyPoint kp2);

/**
 * Default constructor of HarrisLaplace
 */
HarrisLaplace::HarrisLaplace()
{
}

/**
 * Constructor of HarrisLaplace
 * _numOctaves: number of octaves in the gaussian pyramid
 * _corn_thresh: cornerness threshold. The value of the parameter is multiplied by the higher cornerness value. The corners, which cornerness is lower than the product, will be rejected.
 * _DOG_thresh: DoG threshold. Corners that have DoG response lower than _DOG_thresh will be rejected.
 * _maxCorners: Maximum number of keypoints to return. Keypoints returned are the strongest.
 * _num_layers: number of layers in the gaussian pyramid. Accepted value are 2 or 4 so smoothing step between layer will be 1.4 or 1.2
 */
HarrisLaplace::HarrisLaplace(int _numOctaves, float _corn_thresh, float _DOG_thresh, int _maxCorners,
        int _num_layers) :
    numOctaves(_numOctaves), corn_thresh(_corn_thresh), DOG_thresh(_DOG_thresh),
            maxCorners(_maxCorners), num_layers(_num_layers)
{
    assert(num_layers == 2 || num_layers==4);
}

/**
 * Destructor
 */
HarrisLaplace::~HarrisLaplace()
{
}

/**
 * Detect method
 * The method detect Harris corners on scale space as described in
 * "K. Mikolajczyk and C. Schmid.
 * Scale & affine invariant interest point detectors.
 * International Journal of Computer Vision, 2004"
 */
void HarrisLaplace::detect(const Mat & image, vector<KeyPoint>& keypoints) const
{
    Mat_<float> dx2, dy2, dxy;
    Mat Lx, Ly;
    float si, sd;
    int gsize;
    Mat fimage;
    image.convertTo(fimage, CV_32F, 1.f/255);
    /*Build gaussian pyramid*/
    Pyramid pyr(fimage, numOctaves, num_layers, 1, -1, true);
    keypoints = vector<KeyPoint> (0);

    /*Find Harris corners on each layer*/
    for (int octave = 0; octave <= numOctaves; octave++)
    {
        for (int layer = 1; layer <= num_layers; layer++)
        {
            if (octave == 0)
                layer = num_layers;

            Mat Lxm2smooth, Lxmysmooth, Lym2smooth;

            si = pow(2, layer / (float) num_layers);
            sd = si * 0.7;

            Mat curr_layer;
            if (num_layers == 4)
            {
                if (layer == 1)
                {
                    Mat tmp = pyr.getLayer(octave - 1, num_layers - 1);
                    resize(tmp, curr_layer, Size(0, 0), 0.5, 0.5, INTER_AREA);

                } else
                    curr_layer = pyr.getLayer(octave, layer - 2);
            } else /*if num_layer==2*/
            {

                curr_layer = pyr.getLayer(octave, layer - 1);
            }

            /*Calculates second moment matrix*/

            /*Derivatives*/
            Sobel(curr_layer, Lx, CV_32F, 1, 0, 1);
            Sobel(curr_layer, Ly, CV_32F, 0, 1, 1);

            /*Normalization*/
            Lx = Lx * sd;
            Ly = Ly * sd;

            Mat Lxm2 = Lx.mul(Lx);
            Mat Lym2 = Ly.mul(Ly);
            Mat Lxmy = Lx.mul(Ly);

            gsize = ceil(si * 3) * 2 + 1;

            /*Convolution*/
            GaussianBlur(Lxm2, Lxm2smooth, Size(gsize, gsize), si, si, BORDER_REPLICATE);
            GaussianBlur(Lym2, Lym2smooth, Size(gsize, gsize), si, si, BORDER_REPLICATE);
            GaussianBlur(Lxmy, Lxmysmooth, Size(gsize, gsize), si, si, BORDER_REPLICATE);

            Mat cornern_mat(curr_layer.size(), CV_32F);

            /*Calculates cornerness in each pixel of the image*/
            for (int row = 0; row < curr_layer.rows; row++)
            {
                for (int col = 0; col < curr_layer.cols; col++)
                {
                    float dx2f = Lxm2smooth.at<float> (row, col);
                    float dy2f = Lym2smooth.at<float> (row, col);
                    float dxyf = Lxmysmooth.at<float> (row, col);
                    float det = dx2f * dy2f - dxyf * dxyf;
                    float tr = dx2f + dy2f;
                    float cornerness = det - (0.04f * tr * tr);
                    cornern_mat.at<float> (row, col) = cornerness;
                }
            }

            double maxVal = 0;
            Mat corn_dilate;

            /*Find max cornerness value and rejects all corners that are lower than a threshold*/
            minMaxLoc(cornern_mat, 0, &maxVal, 0, 0);
            threshold(cornern_mat, cornern_mat, maxVal * corn_thresh, 0, THRESH_TOZERO);
            dilate(cornern_mat, corn_dilate, Mat());

            Size imgsize = curr_layer.size();

            /*Verify for each of the initial points whether the DoG attains a maximum at the scale of the point*/
            Mat prevDOG, curDOG, succDOG;
            prevDOG = pyr.getDOGLayer(octave, layer - 1);
            curDOG = pyr.getDOGLayer(octave, layer);
            succDOG = pyr.getDOGLayer(octave, layer + 1);

            for (int y = 1; y < imgsize.height - 1; y++)
            {
                for (int x = 1; x < imgsize.width - 1; x++)
                {
                    float val = cornern_mat.at<float> (y, x);
                    if (val != 0 && val == corn_dilate.at<float> (y, x))
                    {

                        float curVal = curDOG.at<float> (y, x);
                        float prevVal =  prevDOG.at<float> (y, x);
                        float succVal = succDOG.at<float> (y, x);

                        KeyPoint kp(
                                Point(x * pow(2, octave - 1) + pow(2, octave - 1) / 2,
                                        y * pow(2, octave - 1) + pow(2, octave - 1) / 2),
                                3 * pow(2, octave - 1) * si * 2, 0, val, octave);

                        /*Check whether keypoint size is inside the image*/
                        float start_kp_x = kp.pt.x - kp.size / 2;
                        float start_kp_y = kp.pt.y - kp.size / 2;
                        float end_kp_x = start_kp_x + kp.size;
                        float end_kp_y = start_kp_y + kp.size;

                        if (curVal > prevVal && curVal > succVal && curVal >= DOG_thresh
                                && start_kp_x > 0 && start_kp_y > 0 && end_kp_x < image.cols
                                && end_kp_y < image.rows)
                            keypoints.push_back(kp);

                    }
                }
            }

        }

    }

    /*Sort keypoints in decreasing cornerness order*/
    sort(keypoints.begin(), keypoints.end(), sort_func);
    for (size_t i = 1; i < keypoints.size(); i++)
    {
        float max_diff = pow(2, keypoints[i].octave + 1.f / 2);
       

        if (keypoints[i].response == keypoints[i - 1].response && norm(
                keypoints[i].pt - keypoints[i - 1].pt) <= max_diff)
        {

            float x = (keypoints[i].pt.x + keypoints[i - 1].pt.x) / 2;
            float y = (keypoints[i].pt.y + keypoints[i - 1].pt.y) / 2;

            keypoints[i].pt = Point(x, y);
            --i;
            keypoints.erase(keypoints.begin() + i);

        }
    }

    /*Select strongest keypoints*/
    if (maxCorners > 0 && maxCorners < (int) keypoints.size())
        keypoints.resize(maxCorners);
    

}
bool sort_func(KeyPoint kp1, KeyPoint kp2)
{
    return (kp1.response > kp2.response);
}

}

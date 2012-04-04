
#ifndef PYRAMID_H_
#define PYRAMID_H_
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>


namespace cv {

class Pyramid
{

protected:
    class Octave
    {
    public:
        vector<Mat> layers;
        Octave();
        Octave(vector<Mat> layers);
        virtual ~Octave();
        vector<Mat> getLayers();
        Mat getLayerAt(int i);
    };

    class DOGOctave
    {
    public:
        vector<Mat> layers;

        DOGOctave();
        DOGOctave(vector<Mat> layers);
        virtual ~DOGOctave();
        vector<Mat> getLayers();
        Mat getLayerAt(int i);
    };

private:
    vector<Octave> octaves;
    vector<DOGOctave> DOG_octaves;
    void build(const Mat& img, bool DOG);
public:
    class Params
    {
    public:
        int octavesN;
        int layersN;
        float sigma0;
        int omin;
        float step;
        Params();
        Params(int octavesN, int layersN, float sigma0, int omin);
        void clear();
    };
    Params params;

    Pyramid();
    Pyramid(const Mat& img, int octavesN, int layersN = 2, float sigma0 = 1, int omin = 0,
            bool DOG = false);
    Mat getLayer(int octave, int layer);
    Mat getDOGLayer(int octave, int layer);
    float getSigma(int octave, int layer);
    float getSigma(int layer);

    virtual ~Pyramid();
    Params getParams();
    void clear();
    bool empty();
};

}  // namespace cv


#endif /* PYRAMID_H_ */
I

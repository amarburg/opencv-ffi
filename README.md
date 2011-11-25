OpenCV-FFI
==========

Status
------

I freely admit this is project is still in-development.  I am using it
for day-to-day work and it will continue to get better, more stable, etc.
It does not cover the whole OpenCV C API, by an stretch -- it needs more
and better tests, really.

I'm very happy to discuss how this project might grow and expand to
become more useful to the Ruby community...


Introduction
------------

An initial attempt at using [Ruby
FFI](https://github.com/ffi/ffi) (actually, relying heavily on
[Nice-FFI](https://github.com/jacius/nice-ffi)) to wrap OpenCV.

Currently developing against
[OpenCV](http://opencv.willowgarage.com/wiki/) 2.3.x pulled from
[SVN](https://code.ros.org/svn/opencv/branches/2.3/opencv/).

Also requires
[Eigen](http://eigen.tuxfamily.org/index.php?title=Main_Page) 3.0.x.
At present I'm developing against the 3.0.2  source tarball available
[here](http://bitbucket.org/eigen/eigen/get/3.0.2.tar.gz).  As noted
below, I'm in the process of removing the external dependencies on Eigen
an others to "plug-ins" which can be monkeypatched in.

This is admittedly a pet project at the moment, so I'm doing a poor job
separating my immediate needs from the "best practices" structure
for the Gem.  

At present this is a three level API:

+ `opencv-ffi` is a "pure" FFI wrapper around the OpenCV C API.  That is,
for each relevant OpenCV struct there is an FFI struct.  For each function
(or at least the ones I've gotten to), there's an `attach_function`
and relatively little else.   Coding with this API is basically 1-to-1
with coding the OpenCV API in C, so it may be necessary to deal with wrapping/unwrapping some of the pricklier types (pointers to pointers and etc).

+ `opencv-ffi-wrappers` is an attempt to create a nicer "more Ruby" API
on top of the pure level, in two ways.   In some cases, OpenCV structs
are extended to give them more object-like APIs.
In other cases new objects are created which wrap around OpenCV objects.

    New objects are often created to hide the typed-ness of OpenCV
    structs.  For example, a `CvPoint2D32F` is different from a
    `CvPoint2D32U`.  A `Point` wrapper, however, could behave more
    interchangably.

    In many cases, OpenCV functions are wrapped with helper functions which handle defaults and type checking incoming data in a more Ruby way.

    For performance reasons, every effort is made to keep data (particularly
CvMat, IplImage, etc) in OpenCV structs as much as possible.

+ `opencv-ffi-ext` is a compiled C extension library which adds new
functionality to the Gem, as I need it.  In some cases this might be an
accelerated backend for a Ruby function.  At present, it also includes a
copy of Edward Rosten's FAST feature detector, compiled from his code,
     and the aforementioned OpenCV-to-Eigen translation layer.  

     In time, any `ext` components which have external dependencies will be moved to "plug-ins" which can be monkey-patched into the CVFFI namespace.  There will be a single native extension remaining, a C/C++-based library `libcvffi` which provides impedence-matching functions between OpenCV and Ruby-FFI, where those functions are missing from OpenCV.

     For example, OpenCV 2.3 provides the SIFT feature detector/descriptor
     algorithm, but only gives a C++ API.  `libcvffi` provides C++-to-C
     wrapper functions to get around this.



Motivation and Project Goals
---

This project was largely inspired by my experiments with OpenCV's C++
interface.  I found experimentation difficult, and always ended up with
verbose code which spent more time converting between data types than
actually performing calculations, particularly given the frequent matrix re-shaping
and construction used in multiple view geometry and stereo vision.
I was constantly refactoring for readability.

I also needed to interface with third-party algorithm libraries like
Eigen, and needed to convert Cv constructs to Eigen constructs, and back.
Inevitably I wrote whole families of interface and helper functions,
but wondered at their long-term utility.

In the end, I decided if I was going to write helper and conversion
functions, I might as well get all of the benefits of coding in Ruby
for free.

The project goals are:

 * Bring OpenCV's algorithms and data types into Ruby.
 * Make it easy to create computer vision programs which are lucid, coherent and easy to read, like good Ruby code.
 * Keep performance as high as possible given all of the above.

Obviously, working in Ruby, time/CPU efficiency isn't your first goal,
but it should be possible to quickly sketch and test an algorithm in Ruby,
then push the computationally expensive elements into C as needed.

Naming
---

Everything is in the `CVFFI` namespace.  OpenCV structures and functions
are named as in OpenCV, with function using the `cvFunctionName`
convention, and structure using the `CvStruct` convention.

Wrappers will generally dispense with the `Cv`/`cv` prefix.  So a
`CvPoint` is an OpenCV CvPoint structures, while a `Point` is its wrapper.


Resources
---

See also {file:docs/DocsIndex.md} for an index of other documentation.

Example code is in the `docs/examples` directory.


Caveats and Second thoughts
---

Arguably, the "wrappers" layer could be split into two layers --
one which adds as much functionality as possible while just extending the OpenCV
structs, and a second which really breaks out into new high-level objects.


License
---

TBD


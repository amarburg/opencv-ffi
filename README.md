OpenCV-FFI
==========

Introduction
------------

An initial attempt at using [Ruby
FFI](https://github.com/ffi/ffi) (actually, relying heavily on
[Nice-FFI](https://github.com/jacius/nice-ffi)) to wrap OpenCV.

Currently developing against
[OpenCV](http://opencv.willowgarage.com/wiki/) 2.3.x pulled from
[SVN](https://code.ros.org/svn/opencv/branches/2.3/opencv/).

Also requires [Eigen](http://eigen.tuxfamily.org/index.php?title=Main_Page) 3.0.x.  At present I'm developing against the 3.0.2  source tarball available [here](http://bitbucket.org/eigen/eigen/get/3.0.2.tar.gz).

This is admittedly a pet project at the moment, so I'm doing a poor job
separating out my immediate needs from the "best practices" structure
for the Gem.  For example, I recently added a dependency on Eigen mostly
as an experiment.  In the future I think it would be smart to remove
the Eigen dependency and make it a separate gem for those who need the
functionality.

At present this is a three level API:

+ `opencv-ffi` is a "pure" FFI wrapper around the OpenCV C API.  That is,
for each relevant OpenCV struct there is an FFI struct.  For each function
(or at least the one's I've gotten to), there's an `attach_function`
with relatively little else.   Coding with this API is basically 1-to-1
with coding the OpenCV API in C.

+ `opencv-ffi-wrappers` is an attempt to create a nicer "more Ruby" API
on top of the pure level, in two ways.   In some cases, OpenCV structs are extended to make them
full Ruby objects with more object-like APIs.  
In other cases new objects are created 
which wrap around OpenCV objects.

    New objects are often created to hide the typed-ness of OpenCV
    structs.  For example, a `CvPoint2D32F` is different from a
    `CvPoint2D32U`.  A `Point` wrapper, however, could behave more
    interchangably.

    In many cases, OpenCV function are wrapped with helper functions which handle defaults and type checking incoming data in a more Ruby way.

    For performance reasons, every effort is made to keep data (particularly
CvMat, IplImage, etc) in OpenCV structs as much as possible.

+ `opencv-ffi-ext` is a compiled C extension library which adds new
functionality to the Gem, as I need it.  In some cases this might be an
accelerated backend for a Ruby function.  At present, it also includes
a copy of Edward Rosten's FAST feature detector, compiled from his code,
and the aforementioned OpenCV-to-Eigen translation layer.

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


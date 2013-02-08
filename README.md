OpenCV-FFI
==========

Status
------

I freely admit this is project is still in development.  I am using it
for day-to-day work in my graduate studies and I hope it will get faster,
more stable, and have better coverage of the OpenCV API faster than it
gets old, out of date, and broken.

I implement OpenCV functions and their wrappers as necessary.  It does
not cover the whole OpenCV C API, by any stretch.  It needs more and
better tests, perhaps as should be expected.

I'm very happy to discuss how this project might grow and expand to
become more useful to the Ruby community...   I'm also open to the
possibility that some of the new APIs (particularly in the wrappers)
could be done differently.


Introduction
------------

An initial attempt at using [Ruby
FFI](https://github.com/ffi/ffi) (actually, relying heavily on
[Nice-FFI](https://github.com/jacius/nice-ffi)) to wrap OpenCV.

__As of January 2013, development has shifted to
[OpenCV](http://opencv.willowgarage.com/wiki/) 2.4 from
[git](https://github.com/Itseez/opencv).  I'm working against the
master branch.__  The original 2.3.x code can be found in the branch *opencv_2.3.x*.

The move to OpenCV 2.4 is something a decision point, the C API to
OpenCV is actually shrinking.  For example, many of the feature detection
algorithms have been ported to a new object hierarchy.  Matching C
functions weren't ported.  Much of the `opencv-ffi-ext` gem (described
in more detail below) is C++-to-C matching functions.  At this point,
working in C is a requirement for using FFI.  It may be that OpenCV+FFI
is a combination destined to fall apart at some point...

At present this is a three level API:

+ `opencv-ffi` is a "pure" FFI wrapper around the OpenCV C API.  For each
relevant OpenCV struct there is an FFI struct.  For each function
(or at least the ones I've gotten to), there's an `attach_function`
and relatively little else.   Coding with this API is basically 1-to-1
with coding the OpenCV API in C, so it may be necessary to deal with
wrapping/unwrapping some of the pricklier types (pointers to pointers
for example).

+ `opencv-ffi-wrappers` is an attempt to create a nicer "more Ruby" API
on top of the pure level, in two ways.   In some cases, OpenCV structs
are extended to give them more object-like APIs.  Of course, in many ways this is re-creating the C++ API in Ruby, on top of C. 

    New objects are often created to hide the typed-ness of OpenCV
    structs.  For example, a `CvPoint2D32F` is different from a
    `CvPoint2D32U`.  A `Point` wrapper, however, could behave more
    interchangably.

    In many cases, OpenCV functions are wrapped with helper functions
    which handle defaults and type checking incoming data in a more
    Ruby way.

    For performance reasons, every effort is made to keep data
    (particularly CvMat, IplImage, etc) in OpenCV structs as much
    as possible.  This means many of the wrapper classes rely on
    delegation, with added functionality layered on top.  Point contains
    a CvPoint2D32F, for example, but can coerce it to a CvPoint2D32U.

    I would expect most users to work primarily with the wrappers.

+ There is a companion gem
[opencv-ffi-ext](https://github.com/amarburg/opencv-ffi-ext) which
contains a compiled C library which adds additional functionality.
These functions were originally included in this Gem, but were removed
so that it wasn't necessary to compile a native extension to use this Gem.

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
 * Make it easy to create computer vision programs which are lucid, coherent and easy to read.
 * Keep performance as high as possible given all of the above.

Obviously, working in Ruby, time/CPU efficiency isn't your first goal,
but it should be possible to quickly sketch and test an algorithm in Ruby,
then push the computationally expensive elements into C as needed.

Naming
---

Everything is in the `CVFFI` namespace.  OpenCV structures and functions
are named as in OpenCV, with functions using the `cvFunctionName`
convention, and structure using the `CvStruct` convention.

Wrappers will generally dispense with the `Cv`/`cv` prefix.  So a
`CvPoint` is an OpenCV CvPoint structure, while a `Point` is its wrapper.


Resources
---

See also {file:docs/DocsIndex.md} for an index of other documentation.

Example code is in the `docs/examples` directory.


License
---

TBD


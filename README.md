OpenCV-FFI
==========

Introduction
------------

An initial attempt at using Ruby FFI to wrap OpenCV.

Currently developing against OpenCV 2.3.1.  Also requires Eigen >= 3.0.0.

This is admittedly a pet project at the moment, so I'm doing a poor job
separating out my immediate needs from the "best practices" structure
for the Gem.  For example, I recently added a dependency on Eigen mostly
as an experiment.  In the future I think it would be smart to remove
the Eigen dependency and make it a separate gem for those who need the
functionality.

At present this is a three level API:

+ _opencv-ffi_ is a "pure" FFI wrapper around the OpenCV C API.  That is,
for each relevant OpenCV struct there is an FFI struct.  For each function
(or at least the one's I've gotten to), there's an `attach_function`
with relatively little else.   Coding with this API is basically 1-to-1
with coding the OpenCV API in C.

+ _opencv-ffi-wrappers_ is an attempt to create a nicer "more Ruby" API
on top of the pure level.  Basically it involves adding new convenience
functions to the OpenCV structures, in some cases creating new objects
which wrap around OpenCV objects, and new functions which also wrap
OpenCV functions.

    For performance reasons, every effort is made to keep data (particularly
CvMat, IplImage, etc) in OpenCV structs as much as possible.  For example,
the IplImage wrapper is wrapped around a cvIplImage struct.  It only
converts away from this data structure when absolutely necessary.

+ _opencv-ffi-ext_ is a compiled C extension library which adds new
functionality to the Gem, as I need it.  In some cases this might be an
accelerated backend for a Ruby function.  At present, it also includes
a copy of Edward Rosten's FAST feature detector, compiled from his code,
and the aforementioned OpenCV-to-Eigen translation layer.

Caveats
---

Arguably, there's room to split the "wrappers" layer into two layers --
one which adds as much functionality as possible just extending the OpenCV
structs, and a second which really breaks out into new high-level objects.
Time will tell.


License
---

TBD


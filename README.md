# This is a Fork of original GTFiber2 https://github.com/Imperssonator/GTFiber2
# GTFiber 2
This is the public-facing repository for GTFiber 2.0. GTFiber is an open source program for automated quantitative analysis of images of fibrillar microstructures.

![demo gif](demo.gif)

See [GTFiber 1.1](https://github.com/Imperssonator/GTFiber-Mac) for the old version that did not vectorize fibers (faster but less rigorous analysis)

## Installing the Standalone App
GTFiber comes with an installer that enables users to run the program without MATLAB.
* IMPORTANT FOR MAC OS SIERRA+: After downloading the repository, you must create a new folder inside the repository folder (it can be called anything, even "untitled") and move "MyAppInstaller_web" into the newly created folder. This somehow convinces Mac OS that the installer app is trustable, even though it was downloaded from the internet.
* [Download](https://github.com/Imperssonator/GTFiber2/archive/master.zip)
the repository, run "MyAppInstaller_web (.exe for Windows, .app for Mac)" and follow the prompts.
It will instruct you to download the Matlab Compiler Runtime, which is approximately 700MB, and is necessary to run MATLAB GUIs outside of the MATLAB environment. 
At the end of installation, it has instructions to change or edit some system files - ignore this and continue. If there are issues, please email me at nils.persson@chbe.gatech.edu.
* Open the installed .app by double-clicking on it. Wait at least one minute, even if it appears nothing is happening on your screen. The Matlab Runtime is being loaded and does not display any message to indicate this is happening.
* You can probably ignore the business about changing your DYLD_LIBRARY_PATH at the end of the installation process.

## Running directly in MATLAB
* [Download](https://github.com/Imperssonator/GTFiber2/archive/master.zip) the repository to your local machine
* Extract the repository to your MATLAB active directory
* Open the extracted folder
* Run `addpath(genpath(pwd))`
* Run `GTFiber`
* Operate the GUI by following the instructions in "Using GTFiber" below
* Running in Matlab provides better access to the raw data and algorithms.

## Using GTFiber

### Loading an Image
* File -> Load Image
* Enter the image's width (not height) in nanometers, with no commas - for example, 5000
* If your image is much larger than 10 µm, instead enter the width in µm and treat every "nm" as if it were "µm"
* Wait until a figure appears showing your original image. This means the program is initialized and ready to run.
* The name of your image will appear at the top of the app as well.

### Choose Filter Parameters
* Each filter parameter has an editable text box. The app scales these parameters automatically based on the image width provided, so try the defaults first. For further tuning, follow the guide in the supporting info of the paper.
* Filter parameters are generally expressed in nanometers so that they work on images of different pixel resolution, but the same physical size
* To view the result after any step of filtering, check its "Display" button

### Run the Filter
* Click "Run Filter" and wait for all progress bars to complete and disappear

### Stitch Fibers
* Click "Stitch Fibers" and wait for the progress bars to complete

### Plot Results
* After both "Run Filter" and "Stitch Fibers", click "Orientational Order" or "Fiber Length/Width" to see plots of various order parameters and structural measurements. Click "Orientation Map" to generate a colored Orientation Map (this is slow).

### Running a Directory of Images
* "Analyze Folder of Images" will apply your current filter parameters to each image file in a specified directory and output the raw results to a .csv file in that directory
* If you would like to save the Orientation Map, Orientation Distribution, and 2D order parameter decay plot as figures for each image, check "Save Figures" below the "Run a Directory..." button
* Allow progress bars to complete, then open the directory to view your results.
* Images in a single directory should be the same physical size, e.g. 5000 x 5000nm, because the specified Image Width will be applied to all

### Examples
GTFiber comes with example images from the protocol paper in which it was introduced, to show what each step looks like with good filter parameters.

* Load an image from the "Example Images" folder, such as "Fig 5A 5000nm.tif"
* Enter the size of the image, specified in the image's file name
* Click "Run Filter", wait for processing to complete
* Click "Stitch Fibers", wait for completion

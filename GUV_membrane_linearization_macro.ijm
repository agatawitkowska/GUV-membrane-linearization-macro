// GUV_membrane_linearization_macro.ijm v1.0.0
// This macro was developed by Agata Witkowska for the study
// Witkowska A. & Jahn R., Biophysical Journal (2017)
// "Rapid SNARE-mediated fusion of liposomes and chromaffin granules with giant unilamellar vesicles"
// http://dx.doi.org/10.1016/j.bpj.2017.03.010

// This Fiji macro can be used for automatic detection of GUV on a microscopy image (1 GUV on image present), linearization of its membrane with a polar transformation method, removal of saturated pixels and measurement of peak membrane intensities on a transformed image. It returns GUV diameter, mean membrane peak intensity and std of it.
// Required plugin: Polar Transformer.

// Clears ROI manager
roiManager("Deselect");
roiManager("Delete");

// Creates directory for saving files
File.makeDirectory(File.directory + File.nameWithoutExtension + "Membrane_Profile");
MacroDir = File.directory + File.nameWithoutExtension + "Membrane_Profile/";

// Returns pixel size of original image needed for future diameter calculations
getPixelSize(unit, pixelWidth, pixelHeight);

run("Duplicate...", " ");

// Provides extended border for circle fitting
run("Canvas Size...", "width=200 height=200 position=Center zero");

saveAs("Tiff", MacroDir + File.nameWithoutExtension + "_ed");
GUVedTIF = File.nameWithoutExtension
GUVed = File.nameWithoutExtension + "_ed.tif";
run("Duplicate...", " ");

// Thresholding for GUV border determination
run("8-bit");
run("Entropy Threshold");
run("Select Bounding Box (guess background color)");
run("Fit Circle");
run("ROI Manager...");
roiManager("Add");
roiManager('select', 0);
roiManager("Rename", "GUV");
selectWindow(GUVed);
roiManager('select', 0);
waitForUser("Pause", "Check Circle Fit"); //  possibility to correct circle fit, make sure to resize existing ROI border
roiManager("Update");
run("Duplicate...", " ");

// Making GUV membrane flat
run("Polar Transformer", "method=Polar degrees=360 default_center for_polar_transforms,");
saveAs("Tiff", MacroDir + GUVedTIF + "_polar");
GUVpolar = GUVedTIF + "_polar.tif"
run("Duplicate...", " ");

selectWindow(GUVpolar);

width = getWidth();
height = getHeight();

run("Set Measurements...", "min display redirect=None decimal=3");


// Removal of saturated pixels
for (y = 0; y < height; y++) {
  for (x = 0; x < width; x++) {
    if (getPixel(x, y) == 65536) setPixel(x, y, 0); // change this accordingly in case of other than 16-bit images
  }
}

maximas = newArray(height);

for (i = 0; i < height; i++) {
  run("Specify...", "width=width height=1 x=0 y=i");
  run("Measure");
  maximas[i] = getResult("Max");
}

Array.getStatistics(maximas, min, max, mean, std);

roiManager('select', 0);
Roi.getBounds(x, y, width, height);

// Log file generation that is a  semicolon-delimited *.txt file with GUV diameter, mean membrane peak fluorescence, and std of it
print(File.nameWithoutExtension + "; " + width * pixelWidth + "; " + mean + ";" + std);

// Cleaning phase
roiManager("Deselect");
roiManager('save', MacroDir + GUVedTIF + "_RoiSet.zip"); // saving ROI list
roiManager("Delete");

selectWindow("Log");
saveAs("Text", MacroDir + GUVedTIF + "_Log.txt"); // saving Log results

selectWindow("Results");
run("Close");

run("Close All");
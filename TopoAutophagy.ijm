run("Close All");
roiManager("reset");
run("Clear Results");
run("Colors...", "foreground=black background=black selection=yellow");
run("Line Width...", "line=1");
setTool("hand");


Dialog.create("Image Information");
  Dialog.addChoice("Zoom Factor:", newArray("0.133", "0.222", "0.333"));
  Dialog.addNumber("Cell Segmentation:", 5);
  //Dialog.addNumber("Cell Segmentation:", 10);
  Dialog.show();
  
  Zoom = Dialog.getChoice();
  Segmentation = Dialog.getNumber();
  //ramp = Dialog.getCheckbox();

dir1 = getDirectory("Choose Source Directory ");
dir2 = getDirectory("Choose Destination Directory"); 
list = getFileList(dir1);

//setBatchMode(true);

for (i = 0; i < list.length; i++){ 
      showProgress(i+1, list.length); 
      open(dir1+list[i]); 

path = dir1+list[i];     
print(path);

// Pre-processing - rotation, ROI selection, making stacks


run("Set Scale...", "distance=1 known="+Zoom+" pixel=1 unit=um global");
rename("All");
run("8-bit");
setTool("line");
waitForUser( "Draw a line to determine the direction of migration ( Draw line toward the direction of migration","OK");
run("Measure");
run("Select None");
a = getResult("Angle", 0); 
run("Rotate... ", "angle="+a+" grid=1 interpolation=Bilinear fill enlarge stack");

run("Clear Results");
setTool("rectangle");
makeRectangle(0, 0, 650, 150);
waitForUser( "makeRectangle","OK");
run("Duplicate...", "duplicate");
selectWindow("All");
close();
selectWindow("All-1");
saveAs("Tiff", dir2+list[i] + " All.tif");
rename("All");
run("Make Substack...", "  slices=1-5");
saveAs("Tiff", dir2+list[i] + " RFP Sub.tif");
rename("RFP");
selectWindow("All");
run("Make Substack...", "  slices=6-10");
saveAs("Tiff", dir2+list[i] + " GFP Sub.tif");
rename("GFP");
selectWindow("All");
run("Make Substack...", "  slices=11-15");
saveAs("Tiff", dir2+list[i] + " CY5 Sub.tif");
rename("CY5");
selectWindow("All");
close();

//Cell identification

selectWindow("GFP");
run("Duplicate...", "title=Mask duplicate");
run("Smooth", "stack");
run("Smooth", "stack");
run("Gaussian Blur...", "sigma=5 stack");
setAutoThreshold("Default dark");
waitForUser( "Apply threshold to mask cell","OK");
run("Fill Holes", "stack");
run("Close-", "stack");
run("Open", "stack");
run("Fill Holes", "stack");
run("Erode", "stack");
run("Dilate", "stack");
run("Erode", "stack");
saveAs("Tiff", dir2+list[i] + " Mask.tif");
rename("Mask");
setSlice(1);
run("Select None");
run("Set Measurements...", "area redirect=None decimal=3");
run("Analyze Particles...", "size=100-infinity add stack");
counts=roiManager("count");
for(j=0; j<counts; j++) 
{
    roiManager("Select", j);
    run("Clear Outside", "slice");
    roiManager("Rename", "slice"+j+"");
    roiManager("Update");
}
roiManager("reset");

//GFP Quantification

selectWindow("GFP");
resetThreshold();
run("Smooth", "stack");
run("Smooth", "stack");
run("Duplicate...", "duplicate");
run("Gaussian Blur...", "sigma=3 stack");
imageCalculator("Subtract create stack", "GFP","GFP-1");
selectWindow("Result of GFP");
setAutoThreshold("Otsu dark no-reset");
waitForUser( "Apply threshold to mask LC3 puncta","OK");
//run("Convert to Mask", "method=MaxEntropy background=Dark calculate black");
run("Fill Holes", "stack");
run("Watershed", "stack");
selectWindow("GFP-1");
close();
selectWindow("GFP");
close();
saveAs("Tiff", dir2+list[i] + " GFP mask.tif");
rename("GFP");

//RFP Quantification

selectWindow("RFP");
resetThreshold();
run("Smooth", "stack");
run("Smooth", "stack");
run("Duplicate...", "duplicate");
run("Gaussian Blur...", "sigma=3 stack");
imageCalculator("Subtract create stack", "RFP","RFP-1");
selectWindow("Result of RFP");
setAutoThreshold("Otsu dark no-reset");
waitForUser( "Apply threshold to mask LC3 puncta","OK");
//run("Convert to Mask", "method=MaxEntropy background=Dark calculate black");
run("Fill Holes", "stack");
run("Watershed", "stack");
selectWindow("RFP-1");
close();
selectWindow("RFP");
close();
saveAs("Tiff", dir2+list[i] + " RFP mask.tif");
rename("RFP");


//CY5 Quantification

selectWindow("CY5");
resetThreshold();
run("Smooth", "stack");
run("Smooth", "stack");
run("Gaussian Blur...", "sigma=4 stack");
waitForUser( "Apply threshold to mask LC3 puncta","OK");
//run("Convert to Mask", "method=MaxEntropy background=Dark calculate black");
run("Fill Holes", "stack");
roiManager("reset");
run("Set Measurements...", "centroid stack redirect=None decimal=3");
run("Analyze Particles...", "size=75-2000 circularity=0.30-1.00 add stack");
counts=roiManager("count");
for(j=0; j<counts; j++) 
{
    roiManager("Select", j);
    run("Clear Outside", "slice");
    run("Measure");  
    
}
roiManager("Show None");
run("Select None");
saveAs("Tiff", dir2+list[i] + " CY5 mask.tif");
rename("CY5");

run("Clear Results");
selectWindow("CY5");
run("Select None");
run("Set Measurements...", "area centroid redirect=None decimal=3");
run("Analyze Particles...", "display stack");
selectWindow("Results"); 
saveAs("Results", dir2+list[i] + " DNA CO-OR.xls");
run("Clear Results");

//measurments

for (t=1; t<=nSlices; t++) { 

roiManager("reset");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel global");
selectWindow("Mask");
run("Select None");
setSlice(t);
run("Analyze Particles...", "add slice");
roiManager("Select", 0); 
run("To Bounding Box");
run("Duplicate...", "title=Mask-"+t+"");
run("Select None");
selectWindow("CY5");
setSlice(t);
roiManager("Select", 0); 
run("To Bounding Box");
run("Duplicate...", "title=CY5-"+t+"");
run("Select None");
selectWindow("RFP");
setSlice(t);
roiManager("Select", 0); 
run("To Bounding Box");
run("Duplicate...", "title=RFP-"+t+"");
run("Select None");
selectWindow("GFP");
setSlice(t);
roiManager("Select", 0); 
run("To Bounding Box");
run("Duplicate...", "title=GFP-"+t+"");
run("Select None");
selectWindow("CY5-"+t+"");
roiManager("reset");
run("Select All");
roiManager("Add");
run("Select None");
run("Set Measurements...", "  centroid redirect=None decimal=3"); 
run("Analyze Particles...", "size=0-Infinity display");
cX=getResult("X",0); 
cY=getResult("Y",0); 
print("X= ",cX, "Y= ",cY); 
run("Clear Results");
selectWindow("Mask-"+t+"");
width = getWidth(); 
height = getHeight(); 
makeRectangle(0, 0, cX, height);
roiManager("Add");
roiManager("Select", 0); 
setKeyDown("alt"); 
roiManager("Select",1); 
setKeyDown("none"); 
roiManager("Add");
roiManager("Select", 0);
roiManager("Delete");
roiManager("Select", 0);
run("Duplicate...", " ");
width = getWidth(); 
height = getHeight(); 
tileWidth = width / Segmentation; 
tileHeight = height;
for (x = 0; x < Segmentation; x++) { 
offsetX = x * width / Segmentation; 
makeRectangle(offsetX, 0, tileWidth, tileHeight); 
roiManager("Add");
}
close();
roiManager("Select", 0);
roiManager("Delete");
roiManager("Select", 0);
run("Duplicate...", " ");
width = getWidth(); 
height = getHeight(); 
tileWidth = width / Segmentation; 
tileHeight = height;
for (x = 0; x < Segmentation; x++) { 
offsetX = x * width / Segmentation; 
makeRectangle(offsetX, 0, tileWidth, tileHeight); 
roiManager("Add");
}
close();
roiManager("Select", 0);
roiManager("Delete");

Sx = cX;
Sy = 0;
r = roiManager("count");
      for (z=Segmentation; z<r; z++) {
          roiManager("Select", z);
          getSelectionBounds(x, y, w, h);
          setSelectionLocation(x+Sx, y+Sy);
          roiManager("update");
      }
roiManager("Save", dir2+list[i] + " RoiSet-"+t+".zip");
run("Set Scale...", "distance=1 known="+Zoom+" pixel=1 unit=um global");
selectWindow("GFP-"+t+"");
counts=roiManager("count");
for(j=0; j<counts; j++) {
    roiManager("Select", j);
    run("Analyze Particles...", "summarize");
}
selectWindow("RFP-"+t+"");
counts=roiManager("count");
for(j=0; j<counts; j++) {
    roiManager("Select", j);
    run("Analyze Particles...", "summarize");
}
selectWindow("Mask-"+t+"");
counts=roiManager("count");
for(j=0; j<counts; j++) {
    roiManager("Select", j);
    run("Analyze Particles...", "summarize");
}
selectWindow("Summary"); 
saveAs("Text", dir2+list[i] + " Summary-"+t+".txt");
run("Close");
roiManager("reset");

close();
close();
close();
close();
}
run("Close All");



#!/usr/bin/perl

use Image::Magick;

$imgfile = shift @ARGV;
$bplname = shift @ARGV;

if (! $imgfile || ! $bplname)
{
	print "Script for converting image file to valheim blueprint (for PlanBuild mod)\n";
	print "usage: img2bpl.pl image_file blueprint_name > blueprint_name.blueprint\n"; 
	exit;
}

$image = new Image::Magick;
$image->Read($imgfile);
die("Error: can not read image from file!") if ! $image->[0];

$w = $image->[0]->Get('columns');
$h = $image->[0]->Get('rows');

# print "Image size is $w / $h\n";

$header = '#Name:~name~
#Creator:img2bpl.pl
#Description:""
#Category:img2bpl
#Pieces
wood_pole;Building;0;0;0;0;1;0;0;"";1;1;1
';

$header =~ s/~name~/$bplname/;
print $header;

$pixsz = 0.2;				# 0.3017578 - 0.1018066;
$xstart = - $w * $pixsz / 2;
#$z1 = $h * $pixsz / 2;
$z1 = $pixsz;
$z2 = $z1 + $pixsz;
$z3 = $z2 + $pixsz;

$pixelt = '<color=#~rgb~>■\n';

$colt = 'sign;Furniture;~x~;~z1~;0;1;0;0;0;"<size=8>~pix1~";0.1;0.1;0.1
sign;Furniture;~x~;~z2~;0;1;0;0;0;"<size=8>~pix2~";1;1;1
sign;Furniture;~x~;~z3~;0;1;0;0;0;"<size=8>~pix3~";1;1;1
';

for($x = 0; $x < $w; $x++)
{
	$col = $colt;
	$pix1 = '\n' x int($h / 2);
	$pix2 = '\n' x int($h / 2);
	$pix3 = '\n' x int($h / 2);
	for($y = 0; $y < int($h / 3); $y ++)
	{
		$pix1t = $pixelt;
		$pix2t = $pixelt;
		$pix3t = $pixelt;

		$rgb1 = get_pixel_rgb($image, $w - $x, $h - $y * 3 + 2);
		$rgb2 = get_pixel_rgb($image, $w - $x, $h - $y * 3 + 1);
		$rgb3 = get_pixel_rgb($image, $w - $x, $h - $y * 3 + 0);
		$pix1t =~ s/~rgb~/$rgb1/;
		$pix2t =~ s/~rgb~/$rgb2/;
		$pix3t =~ s/~rgb~/$rgb3/;
		$pix1 .= $pix1t;
		$pix2 .= $pix2t;
		$pix3 .= $pix3t;
	}
	$col =~ s/~pix1~/$pix1/;
	$col =~ s/~pix2~/$pix2/;
	$col =~ s/~pix3~/$pix3/;
	$col =~ s/~z1~/$z1/;
	$col =~ s/~z2~/$z2/;
	$col =~ s/~z3~/$z3/;
	$col =~ s/~x~/$xstart/g;
	print $col;
	$xstart += $pixsz;
}

sub get_pixel_rgb
{
	$timg = $_[0];
	$xx = $_[1];
	$yy = $_[2];
	@p = $timg->GetPixels(
		'width'   => 1,
		'height'  => 1,
		'x'       => $xx,
		'y'       => $yy,
		map       => 'RGB',
		normalize => 'True',
	);
	return(sprintf("%02x%02x%02x", int($p[0] * 255), int($p[1] * 255), int($p[2] * 255)));
}

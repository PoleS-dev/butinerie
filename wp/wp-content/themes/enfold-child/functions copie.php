<?php

/*
* Add your own functions here. You can also copy some of the theme functions into this file. 
* Wordpress will use those functions instead of the original functions then.
*/

/* Autoriser les fichiers SVG */
function wpc_mime_types($mimes) {
	$mimes['svg'] = 'image/svg+xml';
	return $mimes;
}
add_filter('upload_mimes', 'wpc_mime_types');

add_filter( 'avf_google_heading_font',  'avia_add_heading_font');
function avia_add_heading_font($fonts)
{
$fonts['Spartan:100'] = 'Spartan:100';
	$fonts['Spartan:200'] = 'Spartan:200';
	$fonts['Spartan:300'] = 'Spartan:300';
	$fonts['Spartan:400'] = 'Spartan:400';
	$fonts['Spartan:500'] = 'Spartan:500';
	$fonts['Spartan:600'] = 'Spartan:600';
	$fonts['Spartan:700'] = 'Spartan:700';
	$fonts['Spartan:800'] = 'Spartan:800';
	$fonts['Spartan:900'] = 'Spartan:900';
	$fonts['Yanone Kaffeesatz:300'] = 'Yanone Kaffeesatz:300';
	$fonts['Yanone Kaffeesatz:400'] = 'Yanone Kaffeesatz:400';
	
return $fonts;
}

add_filter( 'avf_google_content_font',  'avia_add_content_font');
function avia_add_content_font($fonts)
{
$fonts['Spartan:100'] = 'Spartan:100';
	$fonts['Spartan:200'] = 'Spartan:200';
	$fonts['Spartan:300'] = 'Spartan:300';
	$fonts['Spartan:400'] = 'Spartan:400';
	$fonts['Spartan:500'] = 'Spartan:500';
	$fonts['Spartan:600'] = 'Spartan:600';
	$fonts['Spartan:700'] = 'Spartan:700';
	$fonts['Spartan:800'] = 'Spartan:800';
	$fonts['Spartan:900'] = 'Spartan:900';
	$fonts['Yanone Kaffeesatz:300'] = 'Yanone Kaffeesatz:300';
	$fonts['Yanone Kaffeesatz:400'] = 'Yanone Kaffeesatz:400';
	
return $fonts;
}
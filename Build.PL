#!/usr/bin/perl -w

use strict;

use Module::Build;

Module::Build->new(
	module_name => 'Algorithm::Dependency::Objects',
	license => 'perl',
	requires => {
		'perl'				=> '5.008',
		'Test::More'		=> '0.47',
		'Scalar::Util'		=> '1.10',
		'Carp'				=> 0,
		'Set::Object'		=> 0,
	},
	create_makefile_pl => 'traditional',
	sign => 1,
)->create_build_script;


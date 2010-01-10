#!/usr/bin/perl
use strict;

my $comment = q(
Milo's test generator
	parses a tex source and generates multiple variants from it
	
	recognizes options (put them in comments):
		!!file_prefix=<text>!!
		!!max_questions=<int>!!
		!!max_answers=<int>!!
		!!variants=<int>!!
	
	
	recognizes 
		\begin{test} - everything prior this will be preserved
		\end{test} - everything after this will be preserved
		\question... marks beggining of the question should not have anything prior it on the line.
			the question ends on next \question, or \end{test}
			\wrong - wrong answer. Becomes \postWrong in generated
			\correct - correct answer. Becomes \postCorrect in generated
		\startQuestion - alternative when \question causes problems
		
	
	replaces
		!!variant!! or !!v!!  - with variant number.
		!!note!! - note about version of the generator
);

my $NOTE = "Generated by mest -0.5";
	
my %vars = (); #variables read from source

sub Rand{
	my $m = shift or warn;
	return int(rand($m));
}

sub Shuffle{
	my @a = @_;
	my $size = scalar @a;
	#warn $size;
	#warn $a[0];
	for(my $i = 0; $i < $size; ++$i){
		my $j = Rand $size;
		my $t = $a[$i];
		$a[$i] = $a[$j];
		$a[$j] = $t;
	}
	return @a;
}

sub GenQuestion{
	my @qsource = @{scalar shift} or warn;
	my $head = '';
	my $foot = '';
	my $state = 'pre'; #pre, post
	my @wrong = ();
	my @correct = ();
	foreach my $q(@qsource){
		#warn "got: $q";
		if($q =~ /^(\s)*\\wrong/){
			$state = 'post';
			push @wrong, $q;
		}
		elsif($q =~ /^(\s)*\\correct/){
			$state = 'post';
			push @correct, $q;
		}
		else{
			if($state eq 'pre'){
				$head .= $q;
			}
			elsif($state eq 'post'){
				$foot .= $q;
			}
			else {
				warn;
			}
		}
	}
	@correct = Shuffle @correct;
	@wrong = Shuffle @wrong;
	#warn @correct;
	
	my @ans = ();
	$correct[0] or warn;
	push @ans, $correct[0];
	for(my $i = 0; $i < $vars{'max_answers'}-1 && $i < scalar @wrong; ++$i){
		push @ans, $wrong[$i];
	}
	@ans = Shuffle @ans;
	
	#warn "ans:@ans";
	my $correctIndex = -1;
	for(my $i = 0; $i < scalar @ans; ++$i){
		$correctIndex = $i if($ans[$i] =~ /^(\s)*\\correct/);
	}
	$correctIndex != -1 or warn;
	my %res = (
		'source' => $head. join('', @ans). $foot,
		'ans' => $correctIndex
	);
	return %res;
}
	
my $file_name = $ARGV[0];
srand(5);

$file_name or die "No filename given!";


	

my $head = ""; #header (prior \begin{test}, inclusive)
my $foot = ""; #footer (after \end{test}, inclusive)

#my @q = (); #$$wrong[question num][] 


my $buf = "";
my $state = 'pre'; # pre, body, que, post
my @questions = (); #array of questions
my @qbuf = (); #current question

my $source;
open $source, $file_name;
while(<$source>){
	if(/\\begin\{test\}/){
		$state='body';
		$head .= $_;
	}
	elsif(/\\end\{test\}/){
		$state eq 'que' or warn;
		if($state eq 'que'){
			#put previous question
			push @questions, \@qbuf;
		}
		$state = 'post';
	}
	elsif($state ne 'pre' && (/^\s*\\question\W/ || /^\s*\\startQuestion\W/)){
		if($state eq 'que'){
			#put previous question
			my @q = @qbuf;
			push @questions, \@q;
		}
		$state = 'que';
		@qbuf = ();
	}
	
	if($state eq 'pre'){
		$head .= $_;
	}
	elsif($state eq 'que'){
		push @qbuf, $_;
	}
	elsif($state eq 'post'){
		$foot .= $_;
	}
}
close $source;


my $qc = scalar @questions;
print "found $qc questions\n";


while($head =~ /!!(\w+)=([^!]+)!!/g){
	print "$1=$2\n";
	$vars{$1}=$2;
}

my @ascending = ();
for(my $i = 0; $i < $qc; ++$i){
	$ascending[$i] = $i;
}

my @letters = (
	'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'и', 'й', 
	'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 
	'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ь', 'ю', 'я'
);

my @ansRows = ();

#if you dont like this behaviour modify it ot make it customizable:
mkdir('out');
system "cp * out/";
chdir('out');

for(my $variant = 1; $variant <= $vars{'variants'}; ++$variant){
	my $v = sprintf("%02d", $variant);
	print "variant: $v\n";
	
	my $fn = $vars{'file_prefix'}.$v.".tex";
	print "$fn\n";
	
	
	my $body = $head;
	
	my @shuffle = Shuffle @ascending;
	my @ans = ($v);
	
	for(my $i = 0; $i < scalar @shuffle && $i < $vars{'max_questions'}; ++$i){
		my %r = GenQuestion $questions[$shuffle[$i]];
		$body .= $r{'source'};
		push @ans, $letters[$r{'ans'}];
		#print $letters{$r{'ans'}};
		#print "$q ";
		#print @{$questions[$q]};
		#print "\n";
		#print %r;
		
	}
	
	push @ansRows, (join('&', @ans)."\\\\\n"."\\hline\n");
	print "\n";
	
	
	$body .= $foot;
	# post process - replace here ...
	
	$body =~ s/!!variant!!/$v/g;
	$body =~ s/!!v!!/$v/g;
	$body =~ s/!!note!!/$NOTE/g;
	$body =~ s/([^{])\\correct/$1\\postCorrect/g;
	$body =~ s/([^{])\\wrong/$1\\postWrong/g;
	
	
	my $file;
	open $file, ">$fn";
	print $file $body;
	close $file;
	
	system "pdflatex -halt-on-error -interaction=batchmode $fn > log";
	
	
}


my $body = $head;
$body .= "\\item :p\n";
$body .= $foot;

my $ansText = "\\hline\n".(join '', @ansRows);
$body =~ s/(\n\s*)\\tableExtra/$1$ansText/g;
$body =~ s/!!note!!/$NOTE/g;

my $fn = $vars{'file_prefix'}.'answers.tex';
print "answers: $fn\n";
my $file;
open $file, ">$fn";
print $file $body;
close $file;

system "pdflatex -halt-on-error -interaction=batchmode $fn > log";

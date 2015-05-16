BT=${BT-../../bin/bedtools}

check()
{
	if diff $1 $2; then
    	echo ok
	else
    	echo fail
	fi
}

###########################################################
#  Test a basic self intersection
############################################################
echo "    intersect.t01...\c"
echo \
"chr1	10	20	a1	1	+
chr1	100	200	a2	2	-" > exp
$BT intersect -a a.bed -b a.bed > obs
check obs exp
rm obs exp

###########################################################
#  Test a basic self intersection with -v
############################################################
echo "    intersect.t02...\c"
# expectation is empty set
touch exp
$BT intersect -a a.bed -b a.bed -v > obs
check obs exp
rm obs exp

###########################################################
#  Test -c
############################################################
echo "    intersect.t03...\c"
echo \
"chr1	10	20	a1	1	+	0
chr1	100	200	a2	2	-	2" > exp
$BT intersect -a a.bed -b b.bed -c > obs
check obs exp
rm obs exp

###########################################################
#  Test -c with -s
############################################################
echo "    intersect.t04...\c"
echo \
"chr1	10	20	a1	1	+	0
chr1	100	200	a2	2	-	1" > exp
$BT intersect -a a.bed -b b.bed -c -s > obs
check obs exp
rm obs exp

###########################################################
#  Test -c with -s and -f
############################################################
echo "    intersect.t05...\c"
echo \
"chr1	10	20	a1	1	+	0
chr1	100	200	a2	2	-	0" > exp
$BT intersect -a a.bed -b b.bed -c -s -f 0.1 > obs
check obs exp
rm obs exp

###########################################################
#  Test plain a and b intersect
############################################################
echo "    intersect.t06...\c"
echo \
"chr1	100	101	a2	2	-
chr1	100	110	a2	2	-" > exp
$BT intersect -a a.bed -b b.bed > obs
check obs exp
rm obs exp

###########################################################
#  Test with -wa
############################################################
echo "    intersect.t07...\c"
echo \
"chr1	100	200	a2	2	-
chr1	100	200	a2	2	-" > exp
$BT intersect -a a.bed -b b.bed -wa > obs
check obs exp
rm obs exp

###########################################################
#  Test with -wa and -wb
############################################################
echo "    intersect.t08...\c"
echo \
"chr1	100	200	a2	2	-	chr1	90	101	b2	2	-
chr1	100	200	a2	2	-	chr1	100	110	b3	3	+" > exp
$BT intersect -a a.bed -b b.bed -wa -wb > obs
check obs exp
rm obs exp

###########################################################
#  Test with -wo (write overlap)
############################################################
echo "    intersect.t09...\c"
echo \
"chr1	100	200	a2	2	-	chr1	90	101	b2	2	-	1
chr1	100	200	a2	2	-	chr1	100	110	b3	3	+	10" > exp
$BT intersect -a a.bed -b b.bed -wo > obs
check obs exp
rm obs exp

###########################################################
#  Test with -wao (write all overlap)
############################################################
echo "    intersect.t10...\c"
echo \
"chr1	10	20	a1	1	+	.	-1	-1	.	-1	.	0
chr1	100	200	a2	2	-	chr1	90	101	b2	2	-	1
chr1	100	200	a2	2	-	chr1	100	110	b3	3	+	10" > exp
$BT intersect -a a.bed -b b.bed -wao > obs
check obs exp
rm obs exp

###########################################################
#  Test with -wo (write overlap) with -s
############################################################
echo "    intersect.t11...\c"
echo \
"chr1	100	200	a2	2	-	chr1	90	101	b2	2	-	1" > exp
$BT intersect -a a.bed -b b.bed -wo -s > obs
check obs exp
rm obs exp


###########################################################
#  Test with -wao (write all overlap) with -s
############################################################
echo "    intersect.t12...\c"
echo \
"chr1	10	20	a1	1	+	.	-1	-1	.	-1	.	0
chr1	100	200	a2	2	-	chr1	90	101	b2	2	-	1" > exp
$BT intersect -a a.bed -b b.bed -wao -s > obs
check obs exp
rm obs exp

###########################################################
#  Test A as -
############################################################
echo "    intersect.t13...\c"
echo \
"chr1	100	101	a2	2	-
chr1	100	110	a2	2	-" > exp
cat a.bed | $BT intersect -a - -b b.bed > obs
check obs exp
rm obs exp

###########################################################
#  Test A as stdin
############################################################
echo "    intersect.t14...\c"
echo \
"chr1	100	101	a2	2	-
chr1	100	110	a2	2	-" > exp
cat a.bed | $BT intersect -a stdin -b b.bed > obs
check obs exp
rm obs exp

###########################################################
#  Test B as -
############################################################
echo "    intersect.t15...\c"
echo \
"chr1	100	101	a2	2	-
chr1	100	110	a2	2	-" > exp
cat b.bed | $BT intersect -a a.bed -b - > obs
check obs exp
rm obs exp

###########################################################
#  Test A as stdin
############################################################
echo "    intersect.t16...\c"
echo \
"chr1	100	101	a2	2	-
chr1	100	110	a2	2	-" > exp
cat b.bed | $BT intersect -a a.bed -b stdin > obs
check obs exp
rm obs exp


###########################################################
###########################################################
#                       -split                            #
###########################################################
###########################################################
samtools view -Sb one_block.sam > one_block.bam 2>/dev/null
samtools view -Sb two_blocks.sam > two_blocks.bam 2>/dev/null
samtools view -Sb three_blocks.sam > three_blocks.bam 2>/dev/null


##################################################################
#  Test three blocks matches BED without -split
##################################################################
echo "    intersect.t17...\c"
echo \
"three_blocks	16	chr1	1	40	10M10N10M10N10M	*	0	0	GAAGGCCACCGCCGCGGTTATTTTCCTTCA	CCCDDB?=FJIIJIGFJIJHIJJJJJJJJI	MD:Z:50" > exp
$BT intersect -abam three_blocks.bam -b three_blocks_nomatch.bed | samtools view - > obs
check obs exp
rm obs exp

##################################################################
#  Test three blocks does not match BED with -split
##################################################################
echo "    intersect.t18...\c"
touch exp
$BT intersect -abam three_blocks.bam -b three_blocks_nomatch.bed -split | samtools view - > obs
check obs exp
rm obs exp

##################################################################
#  Test three blocks matches BED with -split
##################################################################
echo "    intersect.t19...\c"
echo \
"three_blocks	16	chr1	1	40	10M10N10M10N10M	*	0	0	GAAGGCCACCGCCGCGGTTATTTTCCTTCA	CCCDDB?=FJIIJIGFJIJHIJJJJJJJJI	MD:Z:50" > exp
$BT intersect -abam three_blocks.bam -b three_blocks_match.bed -split | samtools view - > obs
check obs exp
rm obs exp

##################################################################
#  Test three blocks does not match BED with -split and -s
#  BAM os -, BED is +
##################################################################
echo "    intersect.t20...\c"
touch exp
$BT intersect -abam three_blocks.bam -b three_blocks_match.bed -split -s | samtools view - > obs
check obs exp
rm obs exp

##################################################################
#  Test three blocks  match BED that overlap 1bp with -split
##################################################################
echo "    intersect.t21...\c"
echo \
"three_blocks	16	chr1	1	40	10M10N10M10N10M	*	0	0	GAAGGCCACCGCCGCGGTTATTTTCCTTCA	CCCDDB?=FJIIJIGFJIJHIJJJJJJJJI	MD:Z:50" > exp
$BT intersect -abam three_blocks.bam -b three_blocks_match_1bp.bed -split | samtools view - > obs
check obs exp
rm obs exp

################################################################################
#  Test three blocks does not match BED that overlap 1bp with -split and -f 0.1
################################################################################
echo "    intersect.t22...\c"
touch exp
$BT intersect -abam three_blocks.bam -b three_blocks_match_1bp.bed -split -f 0.1 | samtools view - > obs
check obs exp
rm obs exp



###########################################################
#  Test three blocks with -split -wo only shows 5 overlap
#  bases, not ten.
############################################################
echo "    intersect.t22.a...\c"
echo "chr1	0	50	three_blocks_match	0	+	0	0	0	3	10,10,10,	0,20,40,	chr1	5	15	5" > exp
$BT intersect -a three_blocks_match.bed -b d.bed -split -wo > obs
check obs exp
rm obs exp

###########################################################
#  Same test but for BAM file
############################################################
echo "    intersect.t22.b...\c"
echo "chr1	0	50	three_blocks_match	255	+	0	50	0,0,0	3	10,10,10,	0,20,40,	chr1	5	15	5" > exp
$BT intersect -a three_blocks_match.bam -b d.bed -split -wo -bed > obs
check obs exp
rm obs exp


###########################################################
#  Test three blocks with -split -wo, and DB record also has
#  blocks that somewhat intersect
############################################################
echo "    intersect.t22.c...\c"
echo "chr1	0	50	three_blocks_match	0	+	0	0	0	3	10,10,10,	0,20,40,	chr1	0	45	three_blocks_match	0	+	0	0	0	2	5,10,	25,35,	10" > exp
$BT intersect -a three_blocks_match.bed -b two_blocks_partial.bed -split -wo > obs
check obs exp
rm obs exp

###########################################################
#  Same test but for BAM file
############################################################
echo "    intersect.t22.d...\c"
echo "chr1	0	50	three_blocks_match	255	+	0	50	0,0,0	3	10,10,10,	0,20,40,	chr1	0	45	three_blocks_match	0	+	0	0	0	2	5,10,	25,35,	10" > exp
$BT intersect -a three_blocks_match.bam -b two_blocks_partial.bed -split -wo -bed > obs
check obs exp
rm obs exp

###########################################################
#  Test three blocks with -split -wo, and DB record also has
#  blocks that do not intersect
############################################################
echo "    intersect.t22.e...\c"
touch exp
$BT intersect -a three_blocks_match.bed -b three_blocks_nomatch.bed -split -wo > obs
check obs exp
rm obs exp


###########################################################
#  Same test but for BAM file
############################################################
echo "    intersect.t22.f...\c"
touch exp
$BT intersect -a three_blocks_match.bam -b three_blocks_nomatch.bed -split -wo -bed > obs
check obs exp
rm obs exp



###########################################################
#  Added split test from bug150. See that overlap bases
# with -split are correctly affected by overlap fraction
############################################################
echo "    intersect.t22.g...\c"
echo \
"chr2	1000	16385	A	0	-	0	0	0	2	1,1,	0,15384,	chr2	1000	16385	A	0	-	0	0	0	2	1,1,	0,15384,	2" > exp
$BT intersect -a bug150_a.bed -b bug150_b.bed -s -split -wo > obs
check exp obs
rm exp obs


##################################################################
#  Test that only the mapped read is is found as an intersection
##################################################################
echo "    intersect.t23...\c"
echo \
"mapped	16	chr1	1	40	30M	*	0	0	GAAGGCCACCGCCGCGGTTATTTTCCTTCA	CCCDDB?=FJIIJIGFJIJHIJJJJJJJJI	MD:Z:50" > exp
samtools view -Sb mapped_and_unmapped.sam 2>/dev/null | $BT intersect -abam - -b a.bed | samtools view - > obs 
check obs exp
rm obs exp

##################################################################
#  Test that an unmapped read is handled properly with -v
##################################################################
echo "    intersect.t24...\c"
echo \
"umapped	4	*	1	40	30M	*	0	0	GAAGGCCACCGCCGCGGTTATTTTCCTTCA	CCCDDB?=FJIIJIGFJIJHIJJJJJJJJI	MD:Z:50" > exp
samtools view -Sb mapped_and_unmapped.sam 2>/dev/null | $BT intersect -abam - -b a.bed -v | samtools view - > obs 
check obs exp
rm obs exp

##################################################################
#  Test -c with BAM input
##################################################################
echo "    intersect.t25...\c"
echo \
"chr1	0	30	one_blocks	40	-	0	30	0,0,0	1	30,	0,	1" > exp
$BT intersect -abam one_block.bam -b c.bed -c -bed > obs
check obs exp
rm obs exp

##################################################################
#  Test -wo with BAM input
##################################################################
echo "    intersect.t26...\c"
echo \
"chr1	0	30	one_blocks	40	-	0	30	0,0,0	1	30,	0,	chr1	0	100	c1	1	+	30" > exp
$BT intersect -abam one_block.bam -b c.bed -wo -bed > obs
check obs exp
rm obs exp

##################################################################
#  Test -wao with BAM input
##################################################################
echo "    intersect.t27...\c"
echo \
"chr1	0	30	one_blocks	40	-	0	30	0,0,0	1	30,	0,	chr1	0	100	c1	1	+	30" > exp
$BT intersect -abam one_block.bam -b c.bed -wo -bed > obs
check obs exp

##################################################################
#  Test BED3 with BED3 
##################################################################
echo "    intersect.t28...\c"
echo \
"chr1^I10^I20^Ichr1^I10^I20" > exp
$BT intersect -a bed3.bed -b bed3.bed -wa -wb | cat -t > obs
check obs exp

##################################################################
#  Test BED4 with BED3 
##################################################################
echo "    intersect.t29...\c"
echo \
"chr1^I10^I20^I345.7^Ichr1^I10^I20" > exp
$BT intersect -a bed4.bed -b bed3.bed -wa -wb | cat -t > obs
check obs exp

##################################################################
#  Test BED5 with BED3 
##################################################################
echo "    intersect.t30...\c"
echo \
"chr1^I10^I20^I345.7^Iwhy?^Ichr1^I10^I20" > exp
$BT intersect -a bed5.bed -b bed3.bed -wa -wb | cat -t > obs
check obs exp

##################################################################
#  Test BED6 (without a proper strand) with BED3 
##################################################################
echo "    intersect.t31...\c"
echo \
"chr1^I10^I20^I345.7^Iwhy?^I11^Ichr1^I10^I20" > exp
$BT intersect -a bed6.bed -b bed3.bed -wa -wb | cat -t > obs
check obs exp

##################################################################
#  Test BED6 (with a strand) with BED3 
##################################################################
echo "    intersect.t32...\c"
echo \
"chr1^I10^I20^I345.7^Iwhy?^I-^Ichr1^I10^I20" > exp
$BT intersect -a bed6.strand.bed -b bed3.bed -wa -wb | cat -t > obs
check obs exp

##################################################################
#  Test BED PLUS with BED3 
##################################################################
echo "    intersect.t33...\c"
echo \
"chr1^I10^I20^I345.7^Iwhy?^I11^Ifoo^Ibar^Ibiz^I11^Ibang^Ibop^I99^Ichr1^I10^I20" > exp
$BT intersect -a bedplus.bed -b bed3.bed -wa -wb | cat -t > obs
check obs exp

##################################################################
#  Test for strand matches with BED3 
##################################################################
echo "    intersect.t34...\c"
echo \
"chr1^I10^I20^I345.7^Iwhy?^I11^Ichr1^I10^I20^I345.7^Iwhy?^I-" > exp
$BT intersect -a bed6.bed -b bed6.strand.bed -wa -wb | cat -t > obs
check obs exp

##################################################################
#  Test for strand matches with BED3 
##################################################################
echo "    intersect.t35...\c"
echo \
"chr1^I10^I20^I345.7^Iwhy?^I-^Ichr1^I10^I20^I345.7^Iwhy?^I-" > exp
$BT intersect -a bed6.strand.bed -b bed6.strand2.bed -wa -wb -s | cat -t > obs
check obs exp

##################################################################
#  Test for strand matches with BED3 
##################################################################
echo "    intersect.t36...\c"
echo \
"chr1^I10^I20^I345.7^Iwhy?^I-^Ichr1^I11^I21^I345.7^Iwhy?^I+" > exp
$BT intersect -a bed6.strand.bed -b bed6.strand2.bed -wa -wb -S | cat -t > obs
check obs exp
rm obs exp

##################################################################
#  Test that intersect of bed query with BAM DB gives Bed output.
##################################################################
echo "    intersect.t37...\c"
echo \
"chr1	10	20	a1	1	+
chr1	100	200	a2	2	-" > exp
$BT intersect -a a.bed -b a.bam > obs
check obs exp
rm obs exp

##################################################################
#  Test that -split works on identical records even if
# -f 1 is ued (100% overlap)
##################################################################
echo "    intersect.t38...\c"
echo \
"chr1	1	100	A	0	+	1	100	0	2	10,10	0,90	chr1	1	100	B	0	+	1	100	0	2	10,10	0,90	20" > exp
$BT intersect -wao  -f 1 -split -a splitBug155_a.bed -b splitBug155_b.bed > obs
check obs exp
rm obs exp

##################################################################
#  Test that fractional overlap must be greater than 0.0
##################################################################
echo "    intersect.t39...\c"
echo \
"***** ERROR: _overlapFraction must be in the range (0.0, 1.0]. *****" > exp
$BT intersect -a a.bed -b b.bed -f 0.0 2>&1 > /dev/null | cat - | head -2 | tail -1 > obs
check exp obs
rm exp obs

##################################################################
#  Test that fractional overlap must be <= than 1.0
##################################################################
echo "    intersect.t40...\c"
echo \
"***** ERROR: _overlapFraction must be in the range (0.0, 1.0]. *****" > exp
$BT intersect -a a.bed -b b.bed -f 1.00001 2>&1 > /dev/null | cat - | head -2 | tail -1 > obs
check exp obs
rm exp obs

##################################################################
#  bug167_strandSweep.bed
##################################################################
echo "    intersect.t41...\c"
echo \
"22" > exp
$BT intersect -a bug167_strandSweep.bed -b bug167_strandSweep.bed -sorted -s -wa -wb | wc -l > obs
check exp obs
rm exp obs

##################################################################
#  bug167_strandSweep.bed
##################################################################
echo "    intersect.t42...\c"
echo \
"20" > exp
$BT intersect -a bug167_strandSweep.bed -b bug167_strandSweep.bed -sorted -S -wa -wb | wc -l > obs
check exp obs
rm exp obs

rm one_block.bam two_blocks.bam three_blocks.bam


##################################################################
# Bug 187 0 length records
##################################################################
echo "    intersect.t43...\c"
echo \
"chr7	33059403	33059403	chr7	33059336	33060883	NT5C3A	intron	0
chr7	33059403	33059403	chr7	32599076	33069221	NAq	intron	0" > exp
$BT intersect -a bug187_a.bed -b bug187_b.bed -wao > obs
check exp obs
rm exp obs

##################################################################
# see that naming conventions are tested with unsorted data.
##################################################################
echo "    intersect.t44...\c"
echo \
"***** WARNING: File nonamecheck_a.bed has a record where naming convention (leading zero) is inconsistent with other files:
chr1	10	20" > exp
$BT intersect -a nonamecheck_a.bed -b nonamecheck_b.bed 2>&1 > /dev/null | cat - | head -2 > obs
check exp obs
rm exp obs


##################################################################
# see that differently named chroms don't work with -sorted
##################################################################
echo "    intersect.t45...\c"
echo \
"***** WARNING: File nonamecheck_b.bed has a record where naming convention (leading zero) is inconsistent with other files:
chr01	15	25" > exp
$BT intersect -a nonamecheck_a.bed -b nonamecheck_b.bed -sorted 2>&1 > /dev/null | cat - | head -2 > obs
check exp obs
rm exp obs

##################################################################
# see that differently named chroms  -sorted and -nonamecheck
# don't complain with -nonamecheck
##################################################################
echo "    intersect.t46...\c"
touch exp
$BT intersect -a nonamecheck_a.bed -b nonamecheck_b.bed -sorted -nonamecheck 2>&1 > /dev/null | cat - > obs
check exp obs
rm exp obs

##################################################################
# see that SVLEN in VCF files is treated as zero length 
# records when the SV type is an insertion
##################################################################
echo "    intersect.t47...\c"
echo \
"chr1	1	a	G	<DEL>	70.90
chr1	1	a	G	<DEL>	70.90
chr1	4	a	G	<INS>	70.90" > exp
$BT intersect -a bug223_sv1_a.vcf -b bug223_sv1_b.vcf | cut -f1-6 > obs
check exp obs
rm exp obs


cd multi_intersect
bash test-multi_intersect.sh
cd ..

cd sortAndNaming
bash test-sort-and-naming.sh
cd ..

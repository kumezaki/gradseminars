function print_set_lengths(     i)
{
	printf("### ")
	for (q = 0; q < lengthQ; q++)
		printf("%d%s",Q[q],(q+1)<lengthQ?" ":"")
	printf(" ###\n")
	return
}

function print_course_permutations(     i,q)
{
	# for each quarter
	for (q = 0; q < lengthQ; q++)
	{
		printf("{ ");

		# for each course (in quarter)
		for (i = 0; i < Q[q]; i++)
		{
			c_pos = QCpos[q,i];
			printf("%d%s ",CNu[c_pos],Cimp[c_pos,q]?"*":"")
#			printf("%d ",c_pos)
		}
					
		printf("}");
	}
	print
	
}

function print_req_calcs(r,     s,q,c)
{
	cu_total_over = 0;
	
	printf("%d",r)
	# for each student
	for (s = 0; s < length(SN); s++)
	{
		printf(" [%s:",SIn[s])

		delete tmp_SU
		for (q = 0; q < lengthQ; q++)
		{
			tmp_SU[q] = SU[s,q]
#			printf("%s%d",q==0?" ":"|",tmp_SU[q])
		}
		
		if (Rpermu[r,s,0] == "")
				printf(" ?")
		else
			for (c = 0; Rpermu[r,s,c] != ""; c++)
			{
				c_pos = Rpermu[r,s,c]
				tmp_SU[CQ[c_pos]] += CU[c_pos]
				printf(" %d(Q%d:%dU)",CNu[c_pos],CQ[c_pos],CU[c_pos])
			}

		for (q = 0; q < lengthQ; q++)
		{
			diff = tmp_SU[q] - SU_OPT;
			printf("%s%d%s",q==0?" ":"|",tmp_SU[q],diff>0?"*":"")
			if (diff > 0)
				cu_total_over += diff;
		}

		printf("]")
	}
	printf(" %d",cu_total_over)
	print
	
	return cu_total_over;
}

function check_min(cu_total_over)
{
	if (cu_total_over <= min_cu_total_over)
	{
		min_cu_total_over = cu_total_over
		
		if (cu_total_over < min_cu_total_over)
		{
			num_min = 0;
			delete min_courses;
			delete min_perms;
		}
		
		for (q = 0; q < lengthQ; q++) # for each quarter
			for (i = 0; i < Q[q]; i++) # for each course (in quarter)
				min_courses[num_min,q,i] = QCpos[q,i];
		min_perms[num_min++] = r;
	}
}

# creates all possible permutations of the number of courses per quarter
function foo(q,num_c,     i,m)
{
	if ((q+1) == lengthQ)
	{
		Q[q] = num_c
		print_set_lengths()
		
		for (m = 0; m < lengthC; m++)
			Cmap[m] = m;

		Ce = lengthC-1
		goo(0,0,0,Ce,Cmap)
	
		return;
	}

	for (i = num_c; i >= 0; i--)
	{
		Q[q] = i
		foo(q+1,num_c-i)
	}
}

function goo(q,pos,Cs,Ce,Cmap,     i,j,m,Cmap_next)
{
	# if pos is # elems in quarter (i.e., quarter set completed)
	if (pos==Q[q])
	{
		# store complementary range (gap) AFTER last element in set
		set_comp[q,pos,0] = Cs	# start
		set_comp[q,pos,1] = Ce	# end

		# check if this is not the last quarter
		if ((q+1)<lengthQ)
		{
			# update Cmap_next (mapping for next quarter)
			m = 0;
			# for each course (in quarter)
			for (i = 0; i <= pos; i++)
			{
				if (set_comp[q,i,1] >= set_comp[q,i,0])
					for (j = set_comp[q,i,0]; j <= set_comp[q,i,1]; j++)
						Cmap_next[m++] = Cmap[j]

#				if (i < pos) printf("%d%s ",CNu[Cmap[set[q,i]]],Cimp[Cmap[set[q,i]],q]?"*":"")
			}

			goo(q+1,0,0,Ce-Q[q],Cmap_next)
		}
		else
		{
			print_course_permutations()
			# for each requirement option
			for (r = 0; r < Rpermu_i; r++)
				check_min(print_req_calcs(r))
		}
		return;
	}
	else
		for (i = Cs; i <= Ce; i++)
		{
			if (Cimp[Cmap[i],q] && test_Cimp)
			{
				# do something here if the course is "impossible"
			}
			else
			{
				set[q,pos] = i 			# store set element
				# store complementary range (gap) BEFORE set element
				set_comp[q,pos,0] = Cs;		# start
				set_comp[q,pos,1] = i-1;	# end

				QCpos[q,pos] = Cmap[i]; # associate quarter set element with course index
				CQ[Cmap[i]] = q; 		# associate course with quarter

				# next lateral element in branch
				goo(q,pos+1,i+1,Ce,Cmap)
			}
		}
}

function hoo(SID,r,     i,j)
{
	if (Sreq[SID,r] == "")
	{
		for (i = 0; i < r; i++)
			SCopt[SID,Ropt_i,i] = R_fulfilled[i];
		Ropt_i++
		return;
	}

	# check all courses
	for (i = 0; Req[Sreq[SID,r],i] != ""; i++)
	{
		course_found_for_req = 0
		# for each course
		for (j = 0; j < lengthC; j++)
			# if it fulfills a req and is not already claimed
			if (Req[Sreq[SID,r],i] == CNu[j] && (!Cclaimed[j]))
			{
				R_fulfilled[r] = j;	# remember course that fulfilled requirement
				Cclaimed[j] = 1
				hoo(SID,r+1)
				Cclaimed[j] = 0
			}
	}
}

function ioo(SID,     Ropt_i,s,c)
{
	if (SID == length(SN))
	{
#		printf("%d ",Rpermu_i)
		for (s = 0; s < SID; s++)
		{
#			printf("[%s:",SIn[s])
			for (c = 0; SCopt[s,SRopt[s],c] != ""; c++)
			{
#				printf(" %d",CNu[SCopt[s,SRopt[s],c]])
				Rpermu[Rpermu_i,s,c] = SCopt[s,SRopt[s],c]
			}
#			printf("]")
		}
		Rpermu_i++
#		print
		return
	}
	
	if (SCopt[SID,0,0] == "")
		ioo(SID+1)
	else
		for (Ropt_i = 0; SCopt[SID,Ropt_i,0] != ""; Ropt_i++)
		{
			SRopt[SID] = Ropt_i
			ioo(SID+1)
		}
}

BEGIN {
	srand();
	
	lengthQ = 3

	SU_OPT = 12;

	# requirements
	r = 0
	Req[r,0] = 0;
	r = 1
	Req[r,0] = 236;
	r = 2
	Req[r,0] = 230; Req[r,1] = 236;
	r = 3
	Req[r,0] = 220; Req[r,1] = 230; Req[r,2] = 235; Req[r,3] = 236;
	r = 4
	Req[r,0] = 131;
	r = 5
	Req[r,0] = 15610;
	r = 6
	Req[r,0] = 15630;
	r = 7
	Req[r,0] = 176;
	r = 8
	Req[r,0] = 1310;
	
	# student info
	SID = 0

	SN[SID] = "Kwan, Adela"; SIn[SID] = "AK"
	SU[SID,0] = 11; SU[SID,1] = 15; SU[SID,2] = 15;
	Sreq[SID,0] = 5
	Sreq[SID,1] = 6
	SID++

	SN[SID] = "Spaulding, Audrey"; SIn[SID] = "AS"
	SU[SID,0] = 11; SU[SID,1] = 15; SU[SID,2] = 13;
	Sreq[SID,0] = 6
	SID++

	SN[SID] = "Gerrard, Jonathan"; SIn[SID] = "JG"
	SU[SID,0] = 7; SU[SID,1] = 11; SU[SID,2] = 7;
	Sreq[SID,0] = 3
	Sreq[SID,1] = 8
	SID++

	SN[SID] = "Tsai, Cynthia"; SIn[SID] = "CT"
	SU[SID,0] = 12; SU[SID,1] = 8; SU[SID,2] = 12;
	SID++

	SN[SID] = "Barb-Mingo, Evyn"; SIn[SID] = "EB-M"
	SU[SID,0] = 9; SU[SID,1] = 9; SU[SID,2] = 13;
	Sreq[SID,0] = 7
	SID++

	SN[SID] = "Okunev, Anna"; SIn[SID] = "AO"
	SU[SID,0] = 6; SU[SID,1] = 12; SU[SID,2] = 6;
	SID++

	SN[SID] = "Caulkins, Anthony"; SIn[SID] = "AC"
	SU[SID,0] = 7; SU[SID,1] = 13; SU[SID,2] = 7;
	SID++

	SN[SID] = "Watson, Jordan"; SIn[SID] = "JW"
	SU[SID,0] = 7; SU[SID,1] = 13; SU[SID,2] = 7;
	Sreq[SID,0] = 2
	SID++

	SN[SID] = "Cheng, Michele"; SIn[SID] = "MC"
	SU[SID,0] = 7; SU[SID,1] = 13; SU[SID,2] = 7;
	Sreq[SID,0] = 2
	SID++

	SN[SID] = "Jones, Molly"; SIn[SID] = "MJ"
	SU[SID,0] = 6; SU[SID,1] = 12; SU[SID,2] = 6;
	Sreq[SID,0] = 1
	SID++

	SN[SID] = "Allen, G. Thomas"; SIn[SID] = "TA"
	SU[SID,0] = 8; SU[SID,1] = 8; SU[SID,2] = 4;
	SID++
	
	# courses being offered
	test_Cimp = 1; # global variable to flag if impossible courses should be tested
	c = 0;
#	CNu[c] = 0; CNa[c] = "BLANK"; CU[c] = 0; c++;
#	CNu[c] = 131; CNa[c] = "Post-Tonal Theory"; CU[c] = 4; Cimp[c,0] = Cimp[c,1] = 1; c++;
	CNu[c] = 1310; CNa[c] = "131 sub"; CU[c] = 4; c++;
	CNu[c] = 15610; CNa[c] = "156A sub"; CU[c] = 2; c++;
	CNu[c] = 15630; CNa[c] = "156C sub"; CU[c] = 2; c++;
	CNu[c] = 176; CNa[c] = "Large Ensemble"; CU[c] = 2; c++;
#	CNu[c] = 200; CNa[c] = "Bibliography"; CU[c] = 4; Cimp[c,1] = Cimp[c,2] = 1;c++;
#	CNu[c] = 201; CNa[c] = "Topics in Analysis"; CU[c] = 4; Cimp[c,0] = Cimp[c,2] = 1; c++;
#	CNu[c] = 209; CNa[c] = "Creative Practices F"; CU[c] = 4; Cimp[c,1] = Cimp[c,2] = 1; c++;
#	CNu[c] = 209; CNa[c] = "Creative Practices W"; CU[c] = 4; Cimp[c,0] = Cimp[c,2] = 1; c++;
#	CNu[c] = 2151; CNa[c] = "Music Technology A"; CU[c] = 4; Cimp[c,1] = Cimp[c,2] = 1; c++;
#	CNu[c] = 2152; CNa[c] = "Music Technology B"; CU[c] = 4; Cimp[c,0] = Cimp[c,2] = 1; c++;
	CNu[c] = 220; CNa[c] = "Mahler"; CU[c] = 4; Cimp[c,1] = Cimp[c,2] = 1; c++;
	CNu[c] = 230; CNa[c] = "Contemporary Music Seminar"; CU[c] = 4; Cimp[c,0] = Cimp[c,1] = 1; c++;
	CNu[c] = 235; CNa[c] = "Critical Studies"; CU[c] = 4; Cimp[c,0] = Cimp[c,2] = 1; c++;
	CNu[c] = 236; CNa[c] = "Theory of World Musics"; CU[c] = 4; Cimp[c,0] = Cimp[c,1] = 1; c++;
#	CNu[c] = 237; CNa[c] = "Lukas tbd"; CU[c] = 4; Cimp[c,0] = Cimp[c,1] = 1; c++;
#	CNu[c] = 237; CNa[c] = "Persian Classical"; CU[c] = 4; Cimp[c,0] = Cimp[c,1] = 1; c++;
#	CNu[c] = 2391; CNa[c] = "ICIT Colloquium 2-unit"; CU[c] = 2; Cimp[c,0] = Cimp[c,2] = 1; c++;
#	CNu[c] = 2392; CNa[c] = "ICIT Colloquium 1-unit"; CU[c] = 1; Cimp[c,0] = Cimp[c,2] = 1; c++;
#	CNu[c] = 276; CNa[c] = "Contemporary Ensemble W"; CU[c] = 2; Cimp[c,0] = Cimp[c,2] = 1; c++;
#	CNu[c] = 276; CNa[c] = "Contemporary Ensemble S"; CU[c] = 2; Cimp[c,0] = Cimp[c,1] = 1; c++;
	lengthC = length(CNa)

	# display info for each course
	for (c = 0; c < lengthC; c++)
		print "["c"] "CNu[c],CNa[c],CU[c]
	print
	
	# display info for each student
	for (SID = 0; SID < length(SN); SID++)
	{
		# print name
		print SN[SID]

		# print committed units for each quarter
		for (q = 0; q < lengthQ; q++)
			print(SU[SID,q])

		# print course number(s) for each requirement
		delete Cclaimed
		Ropt_i = 0
		hoo(SID,0)
		if (SCopt[SID,0,0] == "")
			print "Ropt_i NONE"
		else
			for (Ropt_i = 0; SCopt[SID,Ropt_i,0] != ""; Ropt_i++)
			{
				printf("Ropt_i %d: ",Ropt_i)
				for (c = 0; SCopt[SID,Ropt_i,c] != ""; c++)
					printf("[req %d] %s ",c,CNa[SCopt[SID,Ropt_i,c]])
				print
			}
		print
	}
	
	Rpermu_i = 0
	delete Rpermu
	ioo(0)
	for (r = 0; r < Rpermu_i; r++)
	{
		printf("%d ",r)
		for (s = 0; s < length(SN); s++)
		{
			printf("[%s:",SIn[s])
			for (c = 0; Rpermu[r,s,c] != ""; c++)
				printf(" %d",CNu[Rpermu[r,s,c]])
			printf("]")
		}
		print
	}
	print
	
	min_cu_total_over = 1000000 # a large number
	num_min = 0;
	foo(0,lengthC)
	print "minimum total course units: "min_cu_total_over
	print "occurred "num_min" times"
	prev_min_perms = 0
	start_i = 0
	for (i = 0; i < num_min; i++)
	{
		if (min_perms[i] <= prev_min_perms)
		{
			start_i = i
			print
			delete CQ
			for (q = 0; q < lengthQ; q++) # for each quarter
			{
				for (c = 0; min_courses[i,q,c] != ""; c++) # for each course (in quarter)
				{
					printf "%s%d",(q==0 && c==0)?"":" ",CNu[min_courses[i,q,c]]
					CQ[min_courses[i,q,c]] = q
				}
				if (q < lengthQ-1)
					printf " |"
			}
			print
		}
		printf "%d, %d: ",i,min_perms[i]
		prev_min_perms = min_perms[i];
		print_req_calcs(min_perms[i])
		
		print_num_min_perms = 1
		if (i+1 < num_min)
			if (min_perms[i+1] > prev_min_perms)
				print_num_min_perms = 0
		if (print_num_min_perms)
			print "num permutation options: "(i-start_i+1)
	}
}

{
	split($0,courses,",");
	for (i in courses)
	{
		c = units[courses[i]]
		for (i = 0; i < 3; i++)
		{
		}
	}
#	print s[0,0]"("s[0,0]-u_opt")", s[0,1]"("s[0,1]-u_opt")", s[0,2]"("s[0,2]-u_opt")"
}

END {
}

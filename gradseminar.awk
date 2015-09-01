function print_set_lengths(     i)
{
	printf("### ")
	for (q = 0; q < lengthQ; q++)
		printf("%d%s",Q[q],(q+1)<lengthQ?" ":"")
	printf(" ###\n")
	return
}

function create_course_permuations(     i,j,q,pos)
{
	# initialize course mappings to default (0-0, 1-1, 2-2, etc.)
	for (i = 0; i <= Ce; i++)
		C[i] = i;

	delete QCpos;
	
	# for each quarter
	for (q = 0; q < lengthQ; q++)
	{
		# for each course (in quarter)
		for (i = Q[q]; i > 0; i--)
		{
#			print q,set[q,i],set_comp[q,i,0],set_comp[q,i,1]
			c_pos = C[set[q,i]] # map set element to course pos & store

			if (Cimp[c_pos,q]) return 1;

			QCpos[q,i] = c_pos # map set element to course pos
			CQ[c_pos]=q;
		}
				
		# create index to set_comp elements array
		delete Ctmp;
		pos = 0;
		# for each course (in quarter)
		for (i = Q[q]; i >= 0; i--)
			# for each element in complementary set
			for (j = set_comp[q,i,0]; j <= set_comp[q,i,1]; j++)
			{
#				print q,i,j,pos,C[j]
				Ctmp[pos++] = C[j];
			}
			
		delete C;
#		print "mapping for Q: "q+1
		for (i = 0; i < pos; i++)
		{
			C[i] = Ctmp[i];
#			print "["i"]",C[i]
		}
#		print "*"
	}
	
	return 0;
}

function print_course_permuations(     i,q)
{
	# for each quarter
	for (q = 0; q < lengthQ; q++)
	{
		printf("{ ");

		# for each course (in quarter)
		for (i = Q[q]; i > 0; i--)
		{
			c_pos = QCpos[q,i];
			printf("%d%s ",CNu[c_pos],Cimp[c_pos,q]?"*":"")
#			printf("%d ",c_pos)
		}
					
		printf("}");
	}
	print
	
}

function print_req_calcs(     r,s,c)
{
	# for each requirement option
	for (r = 0; r < Rpermu_i; r++)
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
#				printf("%s%d",q==0?" ":"|",tmp_SU[q])
			}
			
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
	}
}

# creates all possible permutations of the number of courses per quarter
function foo(q,num_c,     i)
{
	if ((q+1) == lengthQ)
	{
		Q[q] = num_c
		print_set_lengths()

		Ce = lengthC-1
		goo(0,Q[0],0,Ce)
	
		return;
	}

	for (i = num_c; i >= 0; i--)
	{
		Q[q] = i
		foo(q+1,num_c-i)
	}
}

function goo(q,pos,Cs,Ce,     i)
{
#	print q,pos,Cs,Ce
	
	if (pos==0)
	{
		set_comp[q,pos,0] = Cs;
		set_comp[q,pos,1] = Ce;
		if ((q+1)<lengthQ)
			goo(q+1,Q[q+1],0,Ce-Q[q])
		else
		{
			num_imp_c = 0;
			if (create_course_permuations() == 0)
				print_course_permuations()
#			if (num_imp_c == 0)
#				print_req_calcs()
		}
		return;
	}
	else
		for (i = Cs; i <= (Ce-pos+1); i++)
		{
			set[q,pos] = i
			set_comp[q,pos,0] = Cs;
			set_comp[q,pos,1] = i-1;
			goo(q,pos-1,i+1,Ce)
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
	Req[r,0] = 1561;
	r = 6
	Req[r,0] = 1563;
	r = 7
	Req[r,0] = 176;
	
	# student info
	SID = 0

#	SN[SID] = "Kwan, Adela"; SIn[SID] = "AK"
#	SU[SID,0] = 11; SU[SID,1] = 15; SU[SID,2] = 15;
#	Sreq[SID,0] = 5
#	Sreq[SID,1] = 6
#	SID++

#	SN[SID] = "Spaulding, Audrey"; SIn[SID] = "AS"
#	SU[SID,0] = 11; SU[SID,1] = 15; SU[SID,2] = 13;
#	Sreq[SID,0] = 6
#	SID++

	SN[SID] = "Gerrard, Jonathan"; SIn[SID] = "JG"
	SU[SID,0] = 7; SU[SID,1] = 11; SU[SID,2] = 7;
	Sreq[SID,0] = 3
	Sreq[SID,1] = 4
	SID++

#	SN[SID] = "Tsai, Cynthia"; SIn[SID] = "CT"
#	SU[SID,0] = 12; SU[SID,1] = 8; SU[SID,2] = 12;
#	Sreq[SID,0] = 0
#	SID++

#	SN[SID] = "Barb-Mingo, Evyn"; SIn[SID] = "EB-M"
#	SU[SID,0] = 9; SU[SID,1] = 9; SU[SID,2] = 13;
#	Sreq[SID,0] = 7
#	SID++

	SN[SID] = "Okunev, Anna"; SIn[SID] = "AO"
	SU[SID,0] = 6; SU[SID,1] = 12; SU[SID,2] = 6;
	Sreq[SID,0] = 0
	SID++

	SN[SID] = "Caulkins, Anthony"; SIn[SID] = "AC"
	SU[SID,0] = 7; SU[SID,1] = 13; SU[SID,2] = 7;
	Sreq[SID,0] = 0
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
	
	# courses being offered
	c = 0;
#	CNu[c] = 0; CNa[c] = "BLANK"; CU[c] = 0; c++;
#	CNu[c] = 131; CNa[c] = "131 sub"; CU[c] = 4; c++;
#	CNu[c] = 1561; CNa[c] = "156A sub"; CU[c] = 2; c++;
#	CNu[c] = 1563; CNa[c] = "156C sub"; CU[c] = 2; c++;
#	CNu[c] = 176; CNa[c] = "Large Ensemble"; CU[c] = 2; c++;
	CNu[c] = 200; CNa[c] = "Bibliography"; Cimp[c,1] = Cimp[c,2] = 1; c++;
	CNu[c] = 201; CNa[c] = "Theory"; CU[c] = 4; Cimp[c,0] = Cimp[c,2] = 1; c++;
	CNu[c] = 209; CNa[c] = "Creative Practices"; Cimp[c,2] = 1; c++;
#	CNu[c] = 2151; CNa[c] = "Music Technology A"; Cimp[c,1] = Cimp[c,2] = 1; c++;
#	CNu[c] = 2152; CNa[c] = "Music Technology B"; Cimp[c,0] = Cimp[c,2] = 1; c++;
#	CNu[c] = 220; CNa[c] = "Mahler"; CU[c] = 4; Cimp[c,1] = Cimp[c,2] = 1; c++;
#	CNu[c] = 230; CNa[c] = "Contemporary Music Seminar"; CU[c] = 4; Cimp[c,0] = Cimp[c,1] = 1; c++;
#	CNu[c] = 235; CNa[c] = "Critical Studies"; CU[c] = 4; Cimp[c,0] = Cimp[c,2] = 1; c++;
#	CNu[c] = 236; CNa[c] = "Theory of World Musics"; CU[c] = 4; Cimp[c,0] = Cimp[c,1] = 1; c++;
#	CNu[c] = 237; CNa[c] = "Lukas tbd"; CU[c] = 4; Cimp[c,0] = Cimp[c,1] = 1; c++;
#	CNu[c] = 237; CNa[c] = "Persian Classical"; CU[c] = 4; Cimp[c,0] = Cimp[c,1] = 1; c++;
#	CNu[c] = 2391; CNa[c] = "ICIT Colloquium 2-unit"; CU[c] = 2; Cimp[c,0] = Cimp[c,2] = 1; c++;
#	CNu[c] = 2392; CNa[c] = "ICIT Colloquium 1-unit"; CU[c] = 1; Cimp[c,0] = Cimp[c,2] = 1; c++;
#	CNu[c] = 276; CNa[c] = "Contemporary Ensemble"; CU[c] = 2; Cimp[c,0] = 1; c++;
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
		
	foo(0,lengthC)
#	print
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

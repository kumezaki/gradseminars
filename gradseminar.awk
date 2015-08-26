function print_set_lengths(     i)
{
	printf("### ")
	for (q = 0; q < lengthQ; q++)
		printf("%d%s",Q[q],(q+1)<lengthQ?" ":"")
	printf(" ###\n")
	return
}

function print_quarter_elems(     i,j,q,pos)
{
	for (i = 0; i <= Ce; i++)
		C[i] = i;

	cu_total_over = 0;
	
	# for each quarter
	for (q = 0; q < lengthQ; q++)
	{
		printf("{ ");

		# for each course (in quarter)
		for (i = Q[q]; i > 0; i--)
		{
			c_pos = C[set[q,i]]
			imp_c = Cimp[c_pos,q]
			if (imp_c) num_imp_c++
			printf("%d%s ",CNu[c_pos],imp_c?"*":"")
#			printf("%d ",c_pos)
			CQ[C[set[q,i]]]=q;
		}
				
		# create index to set_comp elements array
		delete tmp;
		pos = 0;
		for (i = Q[q]; i >= 0; i--)
			for (j = set_comp[q,i,0]; j <= set_comp[q,i,1]; j++)
				tmp[pos++] = C[j];

		delete C;
		for (i = 0; i < pos; i++)
			C[i] = tmp[i];
		
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
				printf("%s%d",q==0?" ":"|",tmp_SU[q])
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
			print_quarter_elems()
			if (num_imp_c == 0)
				print_req_calcs()
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
	Req[0,0] = 220;
	Req[1,0] = 236;
	Req[2,0] = 230; Req[2,1] = 236;
	Req[3,0] = 220; Req[3,1] = 230; Req[3,2] = 235; Req[3,3] = 236;
	
	# student info
	SID = 0
	SN[SID] = "Gerrard, Jonathan"; SIn[SID] = "JG"
	SU[SID,0] = 7; SU[SID,1] = 11; SU[SID,2] = 7;
	Sreq[SID,0] = 3

	SID = 1
	SN[SID] = "Watson, Jordan"; SIn[SID] = "JW"
	SU[SID,0] = 7; SU[SID,1] = 13; SU[SID,2] = 7;
	Sreq[SID,0] = 2

	SID = 2
	SN[SID] = "Cheng, Michele"; SIn[SID] = "MC"
	SU[SID,0] = 7; SU[SID,1] = 13; SU[SID,2] = 7;
	Sreq[SID,0] = 2

	SID = 3
	SN[SID] = "Jones, Molly"; SIn[SID] = "MJ"
	SU[SID,0] = 6; SU[SID,1] = 12; SU[SID,2] = 6;
	Sreq[SID,0] = 1
	
	# courses being offered
	c = 0;
	CNu[c] = 201; CNa[c] = "Schenkerian Analysis"; CU[c] = 4; c++;
	CNu[c] = 220; CNa[c] = "Mahler"; CU[c] = 4; c++;
	CNu[c] = 235; CNa[c] = "Critical Studies"; CU[c] = 4; Cimp[c,0] = Cimp[c,2] = 1; c++;
	CNu[c] = 236; CNa[c] = "Silk Road Music"; CU[c] = 4; c++;
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

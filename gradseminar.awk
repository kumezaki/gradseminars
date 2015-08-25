function print_set_lengths(     i)
{
	printf("### ")
	for (i = lengthQ; i > 0; i--)
		printf("%d%s",Q[i],i>1?" ":"")
	printf(" ###\n")
	return
}

function print_set_elements(     i,j,c,q,r,s,pos)
{
	for (i = 1; i <= Ce; i++)
		C[i] = i;

	cu_total_over = 0;
	
	# for each quarter
	for (q = 1; q <= lengthQ; q++)
	{
		printf("{ ");

		# for each course (in quarter)
		for (i = Q[q]; i > 0; i--)
		{
			printf("%d ",CNu[C[set[q,i]]])
			CQ[C[set[q,i]]]=q;
		}
				
		# create index to set_comp elements array
		delete tmp;
		pos = 1;
		for (i = Q[q]; i >= 0; i--)
			for (j = set_comp[q,i,0]; j <= set_comp[q,i,1]; j++)
				tmp[pos++] = C[j];

		delete C;
		for (i = 1; i < pos; i++)
			C[i] = tmp[i];
		
		printf("} ");
	}
	print

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
			for (q = 1; q <= lengthQ; q++)
			{
				tmp_SU[q] = SU[s,q]
				printf("%s%d",q==1?" ":"|",tmp_SU[q])
			}
			
			for (c = 0; Rpermu[r,s,c] != ""; c++)
			{
				c_pos = Rpermu[r,s,c]
				tmp_SU[CQ[c_pos]] += CU[CQ[c_pos]]
				printf(" %d(%dQ:%dU)",CNu[c_pos],CQ[c_pos],CU[CQ[c_pos]])
			}

			for (q = 1; q <= lengthQ; q++)
			{
				diff = tmp_SU[q] - SU_OPT;
				printf("%s%d%s",q==1?" ":"|",tmp_SU[q],diff>0?"*":"")
				if (diff > 0)
					cu_total_over += diff;
			}

			printf("]")
		}
		printf(" %d",cu_total_over)
		print
	}
}

function foo(q,num_c,     c)
{
	if (q == lengthQ)
	{
		Q[q] = num_c;
		print_set_lengths();

		Ce = lengthC
		goo(1,Q[1],1,Ce);
	
		return;
	}

	for (c = num_c; c >= 0; c--)
	{
		Q[q] = c;
		foo(q+1,num_c-c);
	}
}

function goo(q,pos,Cs,Ce,     i)
{
#	print q,pos,Cs,Ce
	
	if (pos==0)
	{
		set_comp[q,pos,0] = Cs;
		set_comp[q,pos,1] = Ce;
		if (q<lengthQ)
			goo(q+1,Q[q+1],1,Ce-Q[q])
		else
			print_set_elements();
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
		for (j = 1; j <= lengthC; j++)
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
	Req[1,0] = 220;
	Req[2,0] = 236;
	Req[3,0] = 230; Req[3,1] = 236;
	Req[4,0] = 220; Req[4,1] = 230; Req[4,2] = 235; Req[4,3] = 236;
	
	# student info
	SID = 0
	SN[SID] = "Gerrard, Jonathan"; SIn[SID] = "JG"
	SU[SID,1] = 7; SU[SID,2] = 11; SU[SID,3] = 7;
	Sreq[SID,0] = 1
	Sreq[SID,1] = 4

	SID = 1
	SN[SID] = "Watson, Jordan"; SIn[SID] = "JW"
	SU[SID,1] = 7; SU[SID,2] = 13; SU[SID,3] = 7;
	Sreq[SID,0] = 3
	
	# courses being offered
	CNu[1] = 201; CNa[1] = "Schenkerian Analysis"; CU[1] = 4;
	CNu[2] = 220; CNa[2] = "Mahler"; CU[2] = 4;
	CNu[3] = 235; CNa[3] = "Critical Studies"; CU[3] = 4;
	CNu[4] = 236; CNa[4] = "Silk Road Music"; CU[4] = 4;
	lengthC = length(CNa)

	# display info for each course
	for (c = 1; c <= lengthC; c++)
		print "["c"] "CNu[c],CNa[c],CU[c]
	print
	
	# display info for each student
	for (SID = 0; SID < length(SN); SID++)
	{
		# print name
		print SN[SID]

		# print committed units for each quarter
		for (q = 1; q <= lengthQ; q++)
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
		
	foo(1,lengthC)
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

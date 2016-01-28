/* $Id: ex13.mc,v 1.1 2007/07/09 16:25:17 hammes Exp $ */

/*
 * Copyright 2005 SRC Computers, Inc.  All Rights Reserved.
 *
 *	Manufactured in the United States of America.
 *
 * SRC Computers, Inc.
 * 4240 N Nevada Avenue
 * Colorado Springs, CO 80907
 * (v) (719) 262-0213
 * (f) (719) 262-0223
 *
 * No permission has been granted to distribute this software
 * without the express permission of SRC Computers, Inc.
 *
 * This program is distributed WITHOUT ANY WARRANTY OF ANY KIND.
 */

#include <libmap.h>


void subr (int64_t In[], int64_t Out[], int num, int *nret, int64_t *time, int mapnum) {
    OBM_BANK_A (AL, int64_t, MAX_OBM_SIZE)
    OBM_BANK_C (CL, int64_t, MAX_OBM_SIZE)
    int64_t t0, t1;
    Stream_64 S0, S1, SOut;

    read_timer (&t0);

    #pragma src parallel sections
    {
    #pragma src section
	{
	streamed_dma_cpu_64 (&S0, PORT_TO_STREAM,In, num*sizeof(int64_t));
	}

    #pragma src section
	{
    	int i;
    	int64_t v;

        for (i=0; i<num; i++) {
    	   get_stream_64 (&S0, &v);
    	   put_stream_64 (&S1, v, v > 30000);
	    }
	stream_term (&S1);
	}

    #pragma src section
	{
    	int i;
    	int64_t v;

        i = 0;
        while (all_streams_active()) {
    	   get_stream_64 (&S1, &v);

           CL[i] = v * 17;
           i++;
	    }
        *nret = i;
    }
    }

    read_timer (&t1);

    *time = t1 - t0;

    #pragma src parallel sections
    {
    #pragma src section
	{
    	int i;
    	int64_t i64;

         for (i=0;i<*nret;i++) {
           i64 = CL[i];
           put_stream_64 (&SOut, i64, 1);
         }
    }
    #pragma src section
	{
	streamed_dma_cpu_64 (&SOut, STREAM_TO_PORT, Out, *nret*sizeof(int64_t));
	}
    }

}


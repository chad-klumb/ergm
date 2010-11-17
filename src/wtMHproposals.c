#include "wtMHproposals.h"

/* Shorthand. */
#define Mhead (MHp->togglehead)
#define Mtail (MHp->toggletail)
#define Mweight (MHp->toggleweight)

/*********************
 void MH_Poisson

 Default MH algorithm for Poisson-reference ERGM
*********************/
void MH_Poisson(WtMHproposal *MHp, WtNetwork *nwp)  {  
  Vertex head, tail;
  double oldwt, inc;
  int fvalid, trytoggle;
  
  if(MHp->ntoggles == 0) { // Initialize Poisson 
    MHp->ntoggles=1;
    return;
  }
  
  fvalid = 0;
  
  head = 1 + unif_rand() * nwp->nnodes;
  while ((tail = 1 + unif_rand() * nwp->nnodes) == head);
  if (!nwp->directed_flag && head > tail) {
    Mhead[0] = tail;
    Mtail[0] = head;
  }else{
    Mhead[0] = head;
    Mtail[0] = tail;
  }
  
  oldwt = WtGetEdge(Mhead[0],Mtail[0],nwp);
  
  // Choose whether to increment or to decrement.
  inc = (unif_rand()<0.5) ? +1 : -1;
  
  Mweight[0]= oldwt + inc;
  
  fvalid = (Mweight[0]>=0);

  if(!fvalid){
    Mhead[0] = MH_FAILED;
    Mtail[0] = MH_UNSUCCESSFUL;
  }else{
  // Multiply the acceptance ratio by the ratio of reference measures.
  // This is y!/(y+1)! if incrementing and y!/(y-1)! if decrementing.
  MHp->ratio *= inc>0 ? 1.0/Mweight[0] : oldwt;
  }
  
}

/*********************
 void MH_CompleteOrdering

 Default MH algorithm for ERGM over complete orderings
*********************/
void MH_CompleteOrdering(WtMHproposal *MHp, WtNetwork *nwp)  {  
  Vertex head, tail1, tail2;
  double oldwt, inc;
  int fvalid, trytoggle;
  
  if(MHp->ntoggles == 0) { // Initialize Poisson 
    MHp->ntoggles=2;
    return;
  }
  
  head = 1 + unif_rand() * nwp->nnodes;
  while((tail1 = 1 + unif_rand() * nwp->nnodes) == head);
  while((tail2 = 1 + tail1 + unif_rand() * (nwp->nnodes - tail1)) == head);

  Mhead[0] = Mhead[1] = head;
  Mtail[0] = tail1;
  Mtail[1] = tail2;
  
  Mweight[1] = WtGetEdge(Mhead[0],Mtail[0],nwp);
  Mweight[0] = WtGetEdge(Mhead[1],Mtail[1],nwp);
}

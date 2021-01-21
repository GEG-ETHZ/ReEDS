$ontext
No globals needed for this file
$offtext

scalar      cost_scale "scalar for the objective function" /1/ ;
variable    Z "--$-- total cost of either the supply or demand model, scale varies based on cost_scale" ;

eq_ObjFn_Supply.. Z =e=
         sum{t$tmodel(t), cost_scale * pvf_capital(t) *
              (
*investment costs
                   sum{(i,v,r)$valinv(i,v,r,t),
                        INV(i,v,r,t) * (cost_cap_fin_mult(i,r,t) * cost_cap(i,t)

*subtract the present-value of any production tax credits. ptc_unit_value is
*the present-value of all PTC payments for 1 hour of operation at CF=1
                  - ptc_unit_value(i,v,r,t) * sum{h, hours(h) * m_cf(i,v,r,h,t)
                   *(1 - sum{rr$cap_agg(rr,r), curt_int(i,rr,h,t) + curt_marg(i,rr,h,t) }$(not hydro(i))) } ) }

*costs of rsc investment
*Note that cost_cap for hydro and geo techs are zero
*but hydro and geo rsc_fin_mult is equal to the same value as cost_cap_fin_mult
              + sum{(i,v,r,rscbin)$[m_rscfeas(r,i,rscbin)$valinv(i,v,r,t)$rsc_i(i)],

*investment in resource supply curve technologies
                   Inv_RSC(i,v,r,rscbin,t) * m_rsc_dat(r,i,rscbin,"cost") * rsc_fin_mult(i,r,t) }

*costs of refurbishments of RSC tech
              + sum{(i,v,r)$[Sw_Refurb$valinv(i,v,r,t)$refurbtech(i)],
                        (cost_cap_fin_mult(i,r,t) * cost_cap(i,t)
*subtract the present-value of any production tax credits. ptc_unit_value is
*the present-value of all PTC payments for 1 hour of operation at CF=1
                  - ptc_unit_value(i,v,r,t) * sum{h, hours(h)* m_cf(i,v,r,h,t)
                   *(1-sum{rr$cap_agg(rr,r),curt_int(i,rr,h,t)+curt_marg(i,rr,h,t)}$(not hydro(i))) } ) * INV_REFURB(i,v,r,t) }

*costs of transmission lines
              + sum{(r,rr,trtype)$[routes(r,rr,trtype,t)$rfeas(r)$rfeas(rr)],
                        ((cost_tranline(r) + cost_tranline(rr)) / 2) * InvTran(r,rr,t,trtype) * distance(r,rr,trtype) }

*costs of substations
              + sum{(r,vc)$(rfeas(r)$tscfeas(r,vc)),
                        cost_transub(r,vc) * InvSubstation(r,vc,t) }

*cost of back-to-back AC-DC-AC interties
*conditional here that the interconnects must be different
              + sum{(r,rr)$[routes(r,rr,"DC",t)$rfeas(r)$rfeas(rr)$(t.val>2020)$(INr(r) <> INr(rr))],
                        cost_trandctie * InvTran(r,rr,t,"DC") }
*investment in CO2 storage site
               + sum{(r,co2_storage_bins)$[rfeas(r)],
                   cost_cap_fin_mult("co2_storage",r,t) * INV_CS(co2_storage_bins,r,t) * co2_storage_supply(r,"ccost",co2_storage_bins) }
*end to multiplier by pvf_capital
            )
*end of capital cost component of objective function
        }

*===============
*beginning of operational costs (hence pvf_onm and not pvf_capital)
*===============

         + sum{t$tmodel(t), cost_scale * pvf_onm(t) * (
*variable O&M costs
              sum{(i,v,r,h)$[rfeas(r)$valgen(i,v,r,t)$cost_vom(i,v,r,t)],
                   hours(h) * cost_vom(i,v,r,t) * GEN(i,v,r,h,t) }

*fixed O&M costs
              + sum{(i,v,r)$[valcap(i,v,r,t)],
                   cost_fom(i,v,r,t) * CAP(i,v,r,t) }

*operating reserve costs
*only applied to reg reserves because cost of providing other reserves is zero...
              + sum{(i,v,r,h,ortype)$[rfeas(r)$valgen(i,v,r,t)$cost_opres(i)$sameas(ortype,"reg")],
                   hours(h) * cost_opres(i) * OpRes(ortype,i,v,r,h,t) }

*cost of coal and nuclear fuel (except coal used for cofiring)
              + sum{(i,v,r,h)$[rfeas(r)$valgen(i,v,r,t)$(not gas(i))$heat_rate(i,v,r,t)
                              $(not sameas("biopower",i))$(not cofire(i))],
                   hours(h) * heat_rate(i,v,r,t) * fuel_price(i,r,t) * GEN(i,v,r,h,t) }

*cofire coal consumption - cofire bio consumption already accounted for in accounting of BIOUSED
              + sum{(i,v,r,h)$[rfeas(r)$valgen(i,v,r,t)$cofire(i)$heat_rate(i,v,r,t)],
                   (1-bio_cofire_perc) * hours(h) * heat_rate(i,v,r,t)
                   * fuel_price("coal-new",r,t) * GEN(i,v,r,h,t) }

*cost of natural gas for Sw_GasCurve = 2 (static natural gas prices)
              + sum{(i,v,r,h)$[rfeas(r)$valgen(i,v,r,t)$gas(i)$heat_rate(i,v,r,t)
                              $(not sameas("biopower",i))$(not cofire(i))$(Sw_GasCurve = 2)],
                   hours(h) * heat_rate(i,v,r,t) * fuel_price(i,r,t) * GEN(i,v,r,h,t) }

*cost of natural gas for Sw_GasCurve = 0 (census division supply curves natural gas prices)
              + sum{(cendiv,gb)$cdfeas(cendiv), sum{h,hours(h) * GASUSED(cendiv,gb,h,t) }
                   * gasprice(cendiv,gb,t)
                   }$(Sw_GasCurve = 0)

*cost of natural gas for Sw_GasCurve = 3 (national supply curve for natural gas prices with census division multipliers)
              + sum{(h,cendiv,gb)$cdfeas(cendiv),hours(h) * GASUSED(cendiv,gb,h,t)
                   * gasadder_cd(cendiv,t,h) + gasprice_nat_bin(gb,t)
                   }$(Sw_GasCurve = 3)

*cost of natural gas for Sw_GasCurve = 1 (national and census division supply curves for natural gas prices)
*first - anticipated costs of gas consumption given last year's amount
              + (sum{(i,r,v,cendiv,h)$[rfeas(r)$valgen(i,v,r,t)$gas(i)$cdfeas(cendiv)],
                   gasmultterm(cendiv,t) * szn_adj_gas(h) * cendiv_weights(r,cendiv) *
                   hours(h) * heat_rate(i,v,r,t) * GEN(i,v,r,h,t) }

*second - adjustments based on changes from last year's consumption at the regional and national level
              + sum{(fuelbin,cendiv)$cdfeas(cendiv),
                   gasbinp_regional(fuelbin,cendiv,t) * VGASBINQ_REGIONAL(fuelbin,cendiv,t) }

              + sum{(fuelbin),
                   gasbinp_national(fuelbin,t) * VGASBINQ_NATIONAL(fuelbin,t) }

              )$[Sw_GasCurve = 1]

*biofuel consumption
              + sum{(r,bioclass)$rfeas(r),
                   biopricemult(r,bioclass,t) * BIOUSED(bioclass,r,t) * biosupply(r,"cost",bioclass) }

*CO2 transport costs
               + sum{(r,rr)$[rfeas(r)$rfeas(rr)],
                   MAX_CO2_TRANS(r,rr,t) * model_co2_trans_cost}

*CO2 storage costs
               + sum{(r,co2_storage_bins)$[rfeas(r)],
                   TOTAL_CO2_INJECTED(co2_storage_bins,r,t) * co2_storage_supply(r,"acost",co2_storage_bins) }

*Credit for storing CO2
               - sum{(r)$[rfeas(r)],
                 CO2_CAPTURED(r,t)*co2_storage_compensation_rate}

*plus international hurdle costs
              + sum{(r,rr,h,trtype)$[routes(r,rr,trtype,t)$cost_hurdle(r,rr)],
                   cost_hurdle(r,rr) * FLOW(r,rr,h,t,trtype)*hours(h) }

*plus any taxes on emissions
              + sum{(e,r), EMIT(e,r,t) * emit_tax(e,r,t) } * emit_scale

*plus ACP purchase costs
              + sum{(RPSCat,st)$stfeas(st), acp_price(st,t) * ACP_Purchases(RPSCat,st,t)
                   }$(yeart(t)>=RPS_StartYear)
*end multiplier for pvf_onm
         )
*end operations component for objective function
    }

;

libarpack = dlopen("libarpack")

function eigs{T}(A::Matrix{T}, k::Number)

    n = size(A,1)
    ldv = n
    nev = k
    ncv = min(max(nev+1, 20), n)
    bmat = "I"
    which = "LM"
    zero = convert(T, 0.0)
    lworkl = ncv*(ncv+8)

    v = Array(T, n, ncv)
    workd = Array(T, 3*n)
    workl = Array(T, lworkl)
    d = Array(T, nev)
    resid = Array(T, n)
    select = Array(Bool, ncv)
    iparam = Array(Int32, 11)
    ipntr = Array(Int32, 11)

    tol = [zero]
    sigma = [zero]
    info = [0]
    ido = [0]

    ishifts = 1
    maxitr = 1000
    mode1 = 1

    iparam[1] = ishifts
    iparam[3] = maxitr
    iparam[7] = mode1

    while (true)

        # call dsaupd  
        #  ( IDO, BMAT, N, WHICH, NEV, TOL, RESID, NCV, V, LDV, IPARAM,
        #    IPNTR, WORKD, WORKL, LWORKL, INFO )

        ccall(dlsym(libarpack, "dsaupd_"),
              Void,
              (Ptr{Int32}, Ptr{Uint8}, Ptr{Int32}, Ptr{Uint8}, Ptr{Int32},
               Ptr{T}, Ptr{T}, Ptr{Int32}, Ptr{T}, Ptr{Int32}, Ptr{Int32},
               Ptr{Int32}, Ptr{T}, Ptr{T}, Ptr{Int32}, Ptr{Int32}, ),
              ido, bmat, n, which, nev,
              tol, resid, ncv, v, ldv, iparam, 
              ipntr, workd, workl, lworkl, info)

        if (info[1] < 0); print(info[1]); error("Error with saupd"); end
        
        if (ido[1] == -1 || ido[1] == 1)
            workd[ipntr[2]:ipntr[2]+n-1] = A * workd[ipntr[1]:ipntr[1]+n-1]
        else
            break
        end

    end
    
    rvec = true
    all = "A"
    ierr = [0]
    
    # call dseupd ( rvec, 'A', select, d, v, ldv, sigma, 
    #         bmat, n, which, nev, tol, resid, ncv, v, ldv, 
    #         iparam, ipntr, workd, workl, lworkl, ierr )

    ccall(dlsym(libarpack, "dseupd_"),
          Void,
          (Ptr{Bool}, Ptr{Uint8}, Ptr{Bool}, Ptr{T}, Ptr{T}, Ptr{Int32}, Ptr{T}, 
           Ptr{Uint8}, Ptr{Int32}, Ptr{Uint8}, Ptr{Int32}, 
           Ptr{T}, Ptr{T}, Ptr{Int32}, Ptr{T}, Ptr{Int32}, Ptr{Int32}, 
           Ptr{Int32}, Ptr{T}, Ptr{T}, Ptr{Int32}, Ptr{Int32}, ),
          rvec, all, select, d, v, ldv, sigma,
          bmat, n, which, nev,
          tol, resid, ncv, v, ldv, iparam, 
          ipntr, workd, workl, lworkl, ierr)

    if (ierr[1] != 0); error("Error with seupd"); end
    
    return (d, v[1:n, 1:nev])
end
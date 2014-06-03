# -*- coding: utf-8 -*-
"""
Created on Tue Jun 03 16:46:21 2014

@author: LeBronJames
"""

from functools import update_wrapper

def decorator(d):
    """
    Make function d a decorator: d wraps a function fn.
    """
    def _d(fn):
        return update_wrapper(d(fn), fn)
    update_wrapper(_d, d)
    return _d

@decorator
def n_ary(f):
    """
    Given binary function f(x, y), return an n_ary functino such that
    f(x, y, z) = f(x, f(y, z)), etc. Also allow f(x) = x.
    """
    def n_ary_f(x, *args):
        return x if not args else f(x, n_ary_f(*args))
    return n_ary_f

@decorator
def memo(f):
    """
    Decorator that caches the return value for each call to f(args).
    Then when called again with same args, we can just look it up.
    """
    cache = {}
    def _f(*args):
        try:
            return cache[args]
        except KeyError:
            cache[args] = result = f(*args)
            return result
        except TypeError:
            # some element of args can't be a dict key
            return f(args)
    return _f

callcounts = {}
@decorator
def countcalls(f):
    """
    Decorator that makes the function count calls to it, in callcounts[f].
    """
    def _f(*args):
        callcounts[_f] += 1
        return f(*args)
    callcounts[_f] = 0
    return _f

@decorator
def trace(f):
    """
    Decorator that prints the trace tree for calls to f(args)
    """
    indent = '  '
    def _f(*args):
        signature = "%s(%s)" % (f.__name__, ', '.join(map(repr, args)))
        print "%s--> %s" % (trace.level * indent, signature)
        trace.level += 1
        try:
            result = f(*args)
            print '%s<-- %s == %s' % ((trace.level - 1) * indent,
                                      signature, result)
        finally:
            trace.level -= 1
        return result
    trace.level = 0
    return _f

def disabled(f):
    return f

@trace
@countcalls
@memo
def fib(n):
    return 1 if n <= 1 else fib(n - 1) + fib(n - 2)

@n_ary    
def seq(x, y):
    return ('seq', x, y)
    
fib(6)
print callcounts
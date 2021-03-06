% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get.node.attr.R
\name{nodal_attributes}
\alias{nodal_attributes}
\alias{attr}
\alias{attrname}
\alias{on}
\alias{by}
\alias{attrs}
\alias{node.attr}
\alias{nodal.attr}
\alias{vertex.attr}
\alias{node.attribute}
\alias{nodal.attribute}
\alias{vertex.attribute}
\alias{LARGEST}
\alias{SMALLEST}
\alias{COLLAPSE_SMALLEST}
\title{Specifying nodal attributes and their levels}
\usage{
LARGEST(l, a)

SMALLEST(l, a)

COLLAPSE_SMALLEST(object, n, into)
}
\arguments{
\item{object, l, a, n, into}{\code{COLLAPSE_SMALLEST}, \code{LARGEST}, and
\code{SMALLEST} are technically functions but they are generally not
called in a standard fashion but rather as a part of an vertex
attribute specification or a level specification as described
below. The above usage examples are needed to pass \R's package
checking without warnings; please disregard them, and refer to the
sections and examples below instead.}
}
\description{
This document describes the ways to specify nodal
attributes or functions of nodal attributes and which levels for
categorical factors to include. For the helper functions to
facilitate this, see \code{\link{nodal_attributes-API}}.
}
\section{Specifying nodal attributes}{


Term nodal attribute arguments, typically called \code{attr}, \code{attrs}, \code{by}, or
\code{on} are interpreted as follows: \describe{

\item{a character string}{Extract the vertex attribute with
this name.}

\item{a character vector of length > 1}{Extract the vertex
attributes and paste them together, separated by dots if the term
expects categorical attributes and (typically) combine into a
covariate matrix if it expects quantitative attributes.}

\item{a function}{The function is called on the LHS network and
additional arguments to \code{\link[=ergm_get_vattr]{ergm_get_vattr()}}, expected to return a
vector or matrix of appropriate dimension. (Shorter vectors and
matrix columns will be recycled as needed.)}

\item{a formula}{The expression on the RHS of the formula is
evaluated in an environment of the vertex attributes of the
network, expected to return a vector or matrix of appropriate
dimension. (Shorter vectors and matrix columns will be recycled as
needed.) Within this expression, the network itself accessible as
either \code{.} or \code{.nw}. For example,
\code{nodecov(~abs(Grade-mean(Grade))/network.size(.))} would return the
absolute difference of each actor's "Grade" attribute from its
network-wide mean, divided by the network size.}

\item{an \code{AsIs} object created by \code{I()}}{Use as is, checking only
for correct length and type, with optional attribute \code{"name"}
indicating the predictor's name.}

}

Any of these arguments may also be wrapped in or piped through
\code{COLLAPSE_SMALLEST(attr, n, into)} or, \code{attr \%>\% COLLAPSE_SMALLEST(n, into)}, a convenience function that will
transform the attribute by collapsing the smallest \code{n} categories
into one, naming it \code{into}. Note that \code{into} must be of the same
type (numeric, character, etc.) as the vertex attribute in
question.
}

\section{Specifying categorical attribute levels and their ordering}{


For categorical attributes, to select which levels are of interest
and their ordering, use the argument \code{levels}.  Selection of nodes (from
the appropriate vector of nodal indices) is likewise handled as the
selection of levels, using the argument \code{nodes}.  These arguments are interpreted
as follows: \describe{

\item{an expression wrapped in \code{\link[=I]{I()}}}{Use the given list of levels
as is.}

\item{a numeric or logical vector}{Used for indexing of a list of
all possible levels (typically, unique values of the attribute) in
default older (typically lexicographic), i.e.,
\code{sort(unique(attr))[levels]}. In particular, \code{levels=TRUE} will
retain all levels. Negative values exclude. Another special value
is \code{LARGEST}, which will refer to the most frequent category, so,
say, to set such a category as the baseline, pass
\code{levels=-LARGEST}. In addition, \code{LARGEST(n)} will refer to the \code{n}
largest categories. \code{SMALLEST} works analogously. Note that if there
are ties in frequencies, they will be broken arbitrarily. To
specify numeric or logical levels literally, wrap in \code{\link[=I]{I()}}.}

\item{\code{\link{NULL}}}{Retain all possible levels; usually equivalent to
passing \code{TRUE}.}

\item{a character vector}{Use as is.}

\item{a function}{The function is called on the list of unique
values of the attribute, the values of the attribute themselves,
and the network itself, depending on its arity. Its return value is
interpreted as above.}

\item{a formula}{The expression on the RHS of the formula is
evaluated in an environment in which the network itself is
accessible as \code{.nw}, the list of unique values of the attribute as
\code{.} or as \code{.levels}, and the attribute vector itself as
\code{.attr}. Its return value is interpreted as above.}

}

Note that \code{levels} or \code{nodes} often has a default that is sensible for the
term in question.
}

\examples{
library(magrittr) # for \%>\%

data(faux.mesa.high)

# Activity by grade with a baseline grade excluded:
summary(faux.mesa.high~nodefactor(~Grade))
# Retain all levels:
summary(faux.mesa.high~nodefactor(~Grade, levels=TRUE)) # or levels=NULL
# Use the largest grade as baseline (also Grade 7):
summary(faux.mesa.high~nodefactor(~Grade, levels=-LARGEST))
# Activity by grade with no baseline smallest two grades (11 and
# 12) collapsed into a new category, labelled 0:
table(faux.mesa.high \%v\% "Grade")
summary(faux.mesa.high~nodefactor((~Grade) \%>\% COLLAPSE_SMALLEST(2, 0),
                                  levels=TRUE))

# Mixing between lower and upper grades:
summary(faux.mesa.high~mm(~Grade>=10))
# Mixing between grades 7 and 8 only:
summary(faux.mesa.high~mm("Grade", levels=I(c(7,8))))
# or
summary(faux.mesa.high~mm("Grade", levels=1:2))
# or using levels2 (see ? mm) to filter the combinations of levels,
summary(faux.mesa.high~mm("Grade",
        levels2=~sapply(.levels,
                        function(l)
                          l[[1]]\%in\%c(7,8) && l[[2]]\%in\%c(7,8))))

# Activity by grade with a random covariate. Note that setting an attribute "name" gives it a name:
randomcov <- structure(I(rbinom(network.size(faux.mesa.high),1,0.5)), name="random")
summary(faux.mesa.high~nodefactor(I(randomcov)))
}

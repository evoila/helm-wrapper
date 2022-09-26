package main

import (
	"github.com/gin-gonic/gin"
	"helm.sh/helm/v3/pkg/chartutil"
)

func getHelmVersion(c *gin.Context) {
	respOK(c, chartutil.DefaultCapabilities.HelmVersion)
}
